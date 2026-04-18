{ ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # NixOS renders this into /etc/docker/daemon.json.
      registry-mirrors = [
        "https://docker.m.daocloud.io"
      ];

      # Avoid default bridge subnet conflicts on home/lab networks.
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
        {
          base = "172.31.0.0/16";
          size = 24;
        }
      ];

      storage-driver = "overlay2";
      live-restore = true;
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
      features.buildkit = true;
    };
  };
}
