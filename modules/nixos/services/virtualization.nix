{ lib, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # NixOS will render this into /etc/docker/daemon.json.
      "registry-mirrors" = [
        "https://docker.m.daocloud.io"
      ];

      # Avoid default bridge subnet conflicts on home/lab networks.
      "default-address-pools" = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
        {
          base = "172.31.0.0/16";
          size = 24;
        }
      ];

      "storage-driver" = "overlay2";
      "live-restore" = true;
      "log-driver" = "json-file";
      "log-opts" = {
        "max-size" = "10m";
        "max-file" = "3";
      };
      features = {
        buildkit = true;
      };
    };
  };

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
    docker-compose
    docker-buildx
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
