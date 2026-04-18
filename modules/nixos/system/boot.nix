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
  };
}
