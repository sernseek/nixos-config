{ pkgs, ... }:
let
  mkThemeScript =
    {
      name,
      gtkTheme,
      preferDark,
      colorScheme,
    }:
    pkgs.writeShellScript name ''
      mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
      for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
        cat > "$dir/settings.ini" <<EOF
      [Settings]
      gtk-theme-name=${gtkTheme}
      gtk-application-prefer-dark-theme=${if preferDark then "1" else "0"}
      EOF
      done
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'${colorScheme}'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'${gtkTheme}'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-theme ${
        if preferDark then "true" else "false"
      }
      systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service || true
    '';

  themeSetDark = mkThemeScript {
    name = "theme-set-dark";
    gtkTheme = "Adwaita-dark";
    preferDark = true;
    colorScheme = "prefer-dark";
  };

  themeSetLight = mkThemeScript {
    name = "theme-set-light";
    gtkTheme = "Adwaita";
    preferDark = false;
    colorScheme = "prefer-light";
  };

  themeSyncNow = pkgs.writeShellScript "theme-sync-now" ''
    hour=$(${pkgs.coreutils}/bin/date +%H)
    if [ "$hour" -ge 18 ] || [ "$hour" -lt 6 ]; then
      systemctl --user start theme-set-dark.service
    else
      systemctl --user start theme-set-light.service
    fi
  '';

  mkThemeService =
    { description, exec }:
    {
      Unit = {
        inherit description;
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        PartOf = [ "niri.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString exec;
      };
    };

  mkThemeTimer =
    {
      description,
      unit,
      onCalendar,
    }:
    {
      Unit = {
        inherit description;
        PartOf = [ "niri.service" ];
      };
      Timer = {
        Unit = unit;
        OnCalendar = onCalendar;
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
in
{
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  systemd.user.services = {
    theme-set-dark = mkThemeService {
      description = "Set dark theme";
      exec = themeSetDark;
    };
    theme-set-light = mkThemeService {
      description = "Set light theme";
      exec = themeSetLight;
    };
    theme-sync-now =
      (mkThemeService {
        description = "Sync theme by current time";
        exec = themeSyncNow;
      })
      // {
        Install.WantedBy = [ "niri.service" ];
      };
  };

  systemd.user.timers = {
    theme-dark = mkThemeTimer {
      description = "Switch to dark theme at 18:00";
      unit = "theme-set-dark.service";
      onCalendar = "*-*-* 18:00:00";
    };
    theme-light = mkThemeTimer {
      description = "Switch to light theme at 06:00";
      unit = "theme-set-light.service";
      onCalendar = "*-*-* 06:00:00";
    };
  };
}
