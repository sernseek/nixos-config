{ pkgs, ... }:
let
  themeSetDark = pkgs.writeShellScript "theme-set-dark" ''
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<'EOF'
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-application-prefer-dark-theme=1
    EOF
    cat > "$HOME/.config/gtk-4.0/settings.ini" <<'EOF'
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-application-prefer-dark-theme=1
    EOF
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-theme true
    systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service || true
  '';

  themeSetLight = pkgs.writeShellScript "theme-set-light" ''
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<'EOF'
    [Settings]
    gtk-theme-name=Adwaita
    gtk-application-prefer-dark-theme=0
    EOF
    cat > "$HOME/.config/gtk-4.0/settings.ini" <<'EOF'
    [Settings]
    gtk-theme-name=Adwaita
    gtk-application-prefer-dark-theme=0
    EOF
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-theme false
    systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service || true
  '';

  themeSyncNow = pkgs.writeShellScript "theme-sync-now" ''
    hour=$(${pkgs.coreutils}/bin/date +%H)
    if [ "$hour" -ge 18 ] || [ "$hour" -lt 6 ]; then
      systemctl --user start theme-set-dark.service
    else
      systemctl --user start theme-set-light.service
    fi
  '';
in
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  systemd.user.services.theme-set-dark = {
    Unit = {
      Description = "Set dark theme";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${themeSetDark}";
    };
  };

  systemd.user.services.theme-set-light = {
    Unit = {
      Description = "Set light theme";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${themeSetLight}";
    };
  };

  systemd.user.services.theme-sync-now = {
    Unit = {
      Description = "Sync theme by current time";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Install.WantedBy = [ "niri.service" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${themeSyncNow}";
    };
  };

  systemd.user.timers.theme-dark = {
    Unit = {
      Description = "Switch to dark theme at 18:00";
      PartOf = [ "niri.service" ];
    };
    Timer = {
      Unit = "theme-set-dark.service";
      OnCalendar = "*-*-* 18:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.timers.theme-light = {
    Unit = {
      Description = "Switch to light theme at 06:00";
      PartOf = [ "niri.service" ];
    };
    Timer = {
      Unit = "theme-set-light.service";
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.startServices = "sd-switch";
}
