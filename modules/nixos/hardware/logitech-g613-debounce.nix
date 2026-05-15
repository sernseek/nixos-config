{ pkgs, ... }:
let
  logitechG613Debouncer = pkgs.writers.writeRustBin "logitech-g613-debounce" {
    rustcArgs = [ "-O" ];
  } ''
    use std::fs::{File, OpenOptions};
    use std::io::{self, Read, Write};
    use std::mem::{size_of, zeroed};
    use std::os::fd::AsRawFd;
    use std::thread;
    use std::time::{Duration, Instant};

    const DEVICE: &str = "/dev/input/by-id/usb-Logitech_USB_Receiver-event-kbd";
    const DEBOUNCE: Duration = Duration::from_millis(120);
    const KEY_MAX: usize = 0x2ff;

    const EV_SYN: i32 = 0x00;
    const EV_KEY: i32 = 0x01;
    const EV_MSC: i32 = 0x04;
    const MSC_SCAN: i32 = 0x04;
    const BUS_USB: u16 = 0x03;

    const IOC_NRBITS: usize = 8;
    const IOC_TYPEBITS: usize = 8;
    const IOC_SIZEBITS: usize = 14;
    const IOC_NRSHIFT: usize = 0;
    const IOC_TYPESHIFT: usize = IOC_NRSHIFT + IOC_NRBITS;
    const IOC_SIZESHIFT: usize = IOC_TYPESHIFT + IOC_TYPEBITS;
    const IOC_DIRSHIFT: usize = IOC_SIZESHIFT + IOC_SIZEBITS;
    const IOC_WRITE: usize = 1;

    const fn ioc(dir: usize, kind: usize, nr: usize, size: usize) -> usize {
        (dir << IOC_DIRSHIFT)
            | (kind << IOC_TYPESHIFT)
            | (nr << IOC_NRSHIFT)
            | (size << IOC_SIZESHIFT)
    }

    const fn io(kind: usize, nr: usize) -> usize {
        ioc(0, kind, nr, 0)
    }

    const fn iow(kind: usize, nr: usize, size: usize) -> usize {
        ioc(IOC_WRITE, kind, nr, size)
    }

    const UI_SET_EVBIT: usize = iow(b'U' as usize, 100, size_of::<i32>());
    const UI_SET_KEYBIT: usize = iow(b'U' as usize, 101, size_of::<i32>());
    const UI_SET_MSCBIT: usize = iow(b'U' as usize, 107, size_of::<i32>());
    const UI_DEV_CREATE: usize = io(b'U' as usize, 1);
    const UI_DEV_DESTROY: usize = io(b'U' as usize, 2);
    const EVIOCGRAB: usize = iow(b'E' as usize, 0x90, size_of::<i32>());

    #[repr(C)]
    #[derive(Copy, Clone)]
    struct TimeVal {
        tv_sec: i64,
        tv_usec: i64,
    }

    #[repr(C)]
    #[derive(Copy, Clone)]
    struct InputEvent {
        time: TimeVal,
        kind: u16,
        code: u16,
        value: i32,
    }

    #[repr(C)]
    struct InputId {
        bustype: u16,
        vendor: u16,
        product: u16,
        version: u16,
    }

    #[repr(C)]
    struct UInputUserDev {
        name: [u8; 80],
        id: InputId,
        ff_effects_max: u32,
        absmax: [i32; 64],
        absmin: [i32; 64],
        absfuzz: [i32; 64],
        absflat: [i32; 64],
    }

    unsafe extern "C" {
        fn ioctl(fd: i32, request: usize, ...) -> i32;
    }

    fn ioctl_int(file: &File, request: usize, value: i32) -> io::Result<()> {
        let result = unsafe { ioctl(file.as_raw_fd(), request, value) };
        if result < 0 {
            Err(io::Error::last_os_error())
        } else {
            Ok(())
        }
    }

    fn ioctl_none(file: &File, request: usize) -> io::Result<()> {
        let result = unsafe { ioctl(file.as_raw_fd(), request) };
        if result < 0 {
            Err(io::Error::last_os_error())
        } else {
            Ok(())
        }
    }

    fn as_bytes<T>(value: &T) -> &[u8] {
        unsafe { std::slice::from_raw_parts((value as *const T).cast::<u8>(), size_of::<T>()) }
    }

    fn as_bytes_mut<T>(value: &mut T) -> &mut [u8] {
        unsafe { std::slice::from_raw_parts_mut((value as *mut T).cast::<u8>(), size_of::<T>()) }
    }

    struct VirtualDevice {
        file: File,
    }

    impl VirtualDevice {
        fn create() -> io::Result<Self> {
            let mut file = OpenOptions::new().read(true).write(true).open("/dev/uinput")?;

            ioctl_int(&file, UI_SET_EVBIT, EV_SYN)?;
            ioctl_int(&file, UI_SET_EVBIT, EV_KEY)?;
            ioctl_int(&file, UI_SET_EVBIT, EV_MSC)?;
            ioctl_int(&file, UI_SET_MSCBIT, MSC_SCAN)?;
            for code in 0..=KEY_MAX {
                ioctl_int(&file, UI_SET_KEYBIT, code as i32)?;
            }

            let mut device: UInputUserDev = unsafe { zeroed() };
            let name = b"Logitech G613 Debounced";
            device.name[..name.len()].copy_from_slice(name);
            device.id = InputId {
                bustype: BUS_USB,
                vendor: 0x046d,
                product: 0xc53d,
                version: 1,
            };

            file.write_all(as_bytes(&device))?;
            ioctl_none(&file, UI_DEV_CREATE)?;
            thread::sleep(Duration::from_millis(100));

            Ok(Self { file })
        }

        fn write_event(&mut self, event: &InputEvent) -> io::Result<()> {
            self.file.write_all(as_bytes(event))
        }
    }

    impl Drop for VirtualDevice {
        fn drop(&mut self) {
            let _ = ioctl_none(&self.file, UI_DEV_DESTROY);
        }
    }

    fn main() -> io::Result<()> {
        let mut source = OpenOptions::new().read(true).open(DEVICE)?;
        ioctl_int(&source, EVIOCGRAB, 1)?;
        let mut output = VirtualDevice::create()?;

        let mut pressed = [false; KEY_MAX + 1];
        let mut last_press = [None; KEY_MAX + 1];
        let mut suppressed_releases = [0u32; KEY_MAX + 1];

        loop {
            let mut event: InputEvent = unsafe { zeroed() };
            source.read_exact(as_bytes_mut(&mut event))?;

            if event.kind != EV_KEY as u16 || event.code as usize > KEY_MAX {
                output.write_event(&event)?;
                continue;
            }

            let code = event.code as usize;
            match event.value {
                1 => {
                    let elapsed = last_press[code].map(|last: Instant| last.elapsed());
                    let too_soon = elapsed.is_some_and(|duration| duration < DEBOUNCE);
                    if pressed[code] || too_soon {
                        suppressed_releases[code] += 1;
                        continue;
                    }
                    pressed[code] = true;
                    last_press[code] = Some(Instant::now());
                }
                0 if suppressed_releases[code] > 0 => {
                    suppressed_releases[code] -= 1;
                    continue;
                }
                0 => {
                    pressed[code] = false;
                }
                _ => {}
            }

            output.write_event(&event)?;
        }
    }
  '';
in
{
  systemd.services.logitech-g613-debounce = {
    description = "Debounce Logitech G613 key chatter";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${logitechG613Debouncer}/bin/logitech-g613-debounce";
      Restart = "always";
      RestartSec = 2;
    };
  };
}
