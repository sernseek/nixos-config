{ lib, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
    onShutdown = "shutdown";
    allowedBridges = [
      "virbr0"
      "br0"
    ];

    qemu = {
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    virtio-win
    virt-viewer
  ];

  networking.firewall.trustedInterfaces = [
    "virbr0"
    "br0"
  ];

  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.runtimeShell} -c 'umask 0077 && ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/libvirt/secrets && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  ];
}
