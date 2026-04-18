{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Bridge Wayland clipboard → X11 CLIPBOARD on the xwayland-satellite display
  # (:0). xwayland-satellite has a known bug where wl→X sync stops working after
  # a while; this service watches the Wayland clipboard and re-publishes each
  # change to X11 via xsel, which forks to keep the selection alive.
  # Safe: no loop because xsel writes an X11 selection, which doesn't trigger
  # wl-paste --watch (which only reacts to Wayland clipboard changes).
  systemd.user.services.wl-to-xwayland-clipboard = {
    Unit = {
      Description = "Sync Wayland clipboard to XWayland (:0)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.xsel}/bin/xsel -ib";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.startServices = "sd-switch";
}
