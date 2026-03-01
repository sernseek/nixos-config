{ pkgs, ... }:
{
  services.mihomo = {
    enable = true;
    package = pkgs.mihomo;
    tunMode = true;
    webui = pkgs.metacubexd;
    configFile = "/etc/nixos/secrets/mihomo-config.yaml";
    extraOpts = "-d /var/lib/mihomo";
  };

  systemd.services.mihomo.serviceConfig = {
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_PACKET"
    ];
  };
}
