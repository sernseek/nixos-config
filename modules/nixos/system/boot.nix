{ ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      systemd.enable = true;
      luks.devices."crypted".crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      # AMD SME only; leave disabled on Intel hosts.
      # "mem_encrypt=on"
    ];

    # DDR5 SPD hub driver breaks S3 resume on Intel 12th gen+ laptops
    # (spd5118_resume returns -ENXIO → system hangs on wake). Only provides
    # DIMM temperature sensors, which we don't need.
    blacklistedKernelModules = [ "spd5118" ];
  };
}
