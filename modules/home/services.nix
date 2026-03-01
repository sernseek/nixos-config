{ pkgs, ... }:
{
  systemd.user.services.darkman-set-dark = {
    Unit = {
      Description = "Set dark mode (fixed time)";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.darkman}/bin/darkman set dark";
    };
  };

  systemd.user.services.darkman-set-light = {
    Unit = {
      Description = "Set light mode (fixed time)";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.darkman}/bin/darkman set light";
    };
  };

  systemd.user.timers.darkman-dark = {
    Unit = {
      Description = "Switch to dark mode at 18:00";
      PartOf = [ "niri.service" ];
    };
    Timer = {
      Unit = "darkman-set-dark.service";
      OnCalendar = "*-*-* 18:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.timers.darkman-light = {
    Unit = {
      Description = "Switch to light mode at 06:00";
      PartOf = [ "niri.service" ];
    };
    Timer = {
      Unit = "darkman-set-light.service";
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.startServices = "sd-switch";
}
