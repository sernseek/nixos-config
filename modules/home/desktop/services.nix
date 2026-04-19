{ pkgs, ... }:
let
  # Wayland → XWayland(:0) clipboard sync with content dedup to avoid the
  # feedback loop that kills the Wayland selection after a few hours.
  # Reverse direction (X11 → Wayland) is handled by xwayland-satellite.
  wl2xClipboardSync = pkgs.writeShellScript "wl2x-clipboard-sync" ''
    set -u
    export PATH=${pkgs.wl-clipboard}/bin:${pkgs.xsel}/bin:${pkgs.coreutils}/bin:$PATH
    exec wl-paste --watch sh -c '
      wl=$(mktemp) || exit 0
      x=$(mktemp) || { rm -f "$wl"; exit 0; }
      trap "rm -f \"$wl\" \"$x\"" EXIT
      wl-paste -n > "$wl" 2>/dev/null || exit 0
      [ -s "$wl" ] || exit 0
      DISPLAY=:0 xsel -ob > "$x" 2>/dev/null || true
      cmp -s "$wl" "$x" && exit 0
      DISPLAY=:0 xsel -ib < "$wl"
    '
  '';
in
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Pushes Wayland CLIPBOARD → XWayland(:0) on every change, skipping writes
  # when the X11 selection already matches — breaks the satellite feedback loop
  # that previously froze Wayland apps after a few hours.
  systemd.user.services.wl2x-clipboard-sync = {
    Unit = {
      Description = "Sync Wayland clipboard to XWayland (:0)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${wl2xClipboardSync}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.startServices = "sd-switch";
}
