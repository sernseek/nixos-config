{ config, pkgs, ... }:
let
  smi = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi";
  # On AC, hold a graphics-clock floor so the GPU does not idle down to
  # ~240MHz/P8. From that floor the ramp on bursty work (e.g. opening the niri
  # overview after a few idle minutes) is short enough that the recurring "first
  # action stutters, then smooth" P-state lag disappears. On battery, reset to
  # the default fully-dynamic curve so idle power stays minimal.
  gpuClockPolicy = pkgs.writeShellScript "nvidia-clock-policy" ''
    set -u
    ${smi} -pm 1 >/dev/null 2>&1 || true
    online=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -n1 || echo 1)
    if [ "$online" = "1" ]; then
      ${smi} -lgc 800,3105 >/dev/null 2>&1 || true
    else
      ${smi} -rgc >/dev/null 2>&1 || true
    fi
  '';
in
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      # Saves/restores video memory across S3 so the GPU wakes up cleanly
      # instead of hitting "Flip event timeout on head 0". Requires
      # hardware.nvidia.open = true on driver 560+, otherwise GUI fails to
      # start after rebuild (learned the hard way).
      enable = true;
    };
    # NVIDIA open kernel modules (still proprietary userspace). Required for
    # suspend/resume + powerManagement to work on driver 560+ for Turing/Ada.
    # Our RTX 4070 Mobile (Ada) is officially supported.
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  # Apply the AC/battery GPU clock policy at boot and re-apply whenever the
  # AC adapter is plugged or unplugged.
  systemd.services.nvidia-clock-policy = {
    description = "Set NVIDIA GPU clock floor based on AC power state";
    wantedBy = [ "multi-user.target" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = gpuClockPolicy;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl start --no-block nvidia-clock-policy.service"
  '';
}
