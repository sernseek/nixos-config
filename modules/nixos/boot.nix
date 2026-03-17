{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    # AMD SME only; leave disabled on Intel hosts.
    # "mem_encrypt=on"
  ];
  boot.initrd.luks.devices."crypted" = {
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
}
