{ pkgs, ... }:
{
  services.mihomo = {
    enable = true;
    package = pkgs.mihomo;
    tunMode = true;
    webui = pkgs.metacubexd;
    # Read as root via systemd LoadCredential, exposed to mihomo via
    # $CREDENTIALS_DIRECTORY. 0600 perms on the source file are fine.
    configFile = "/etc/nixos/nixos-secrets/mihomo-config.yaml";
    extraOpts = "-d /var/lib/mihomo";
  };

  systemd.services.mihomo.serviceConfig = {
    # Run as root (the `+` prefix) so we can read 0600 secrets owned by
    # `sernseek` and chown the copies to mihomo's DynamicUser.
    # The default preStart runs as the dynamic user, which cannot read
    # the locked-down source directory — leaving providers stale.
    ExecStartPre = [
      ("+" + (pkgs.writeShellScript "mihomo-load-providers" ''
        set -eu
        shopt -s nullglob
        install -d -m 0700 -o mihomo -g mihomo /var/lib/mihomo/providers
        for file in /etc/nixos/nixos-secrets/providers/*; do
          install -m 0600 -o mihomo -g mihomo "$file" \
            /var/lib/mihomo/providers/"$(basename "$file")"
        done
      '').outPath)
    ];

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_PACKET"
    ];

    # Low-risk systemd hardening. mihomo's StateDirectory (/var/lib/mihomo)
    # remains writable; /usr /boot /etc go read-only; /home is hidden.
    # If startup breaks, comment out ProtectKernelModules first (TUN device).
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
  };
}
