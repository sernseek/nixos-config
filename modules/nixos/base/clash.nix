{ pkgs, ... }:
{
  services.mihomo = {
    enable = true;
    package = pkgs.mihomo;
    tunMode = true;
    webui = pkgs.metacubexd;
    configFile = "/etc/nixos/nixos-secrets/mihomo-config.yaml";
    extraOpts = "-d /var/lib/mihomo";
  };

  systemd.services.mihomo = {
    preStart = ''
      ${pkgs.coreutils}/bin/install -d -m 0755 /var/lib/mihomo/providers

      for file in /etc/nixos/nixos-secrets/providers/*; do
        [ -f "$file" ] || continue
        ${pkgs.coreutils}/bin/install -m 0644 "$file" /var/lib/mihomo/providers/"$(${pkgs.coreutils}/bin/basename "$file")"
      done
    '';

    serviceConfig = {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_PACKET"
      ];
    };
  };
}
