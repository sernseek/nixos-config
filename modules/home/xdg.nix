{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };

  xdg.desktopEntries.code = {
    name = "Visual Studio Code";
    genericName = "Text Editor";
    exec = "${pkgs.vscode}/bin/code --password-store=gnome-libsecret %F";
    icon = "vscode";
    terminal = false;
    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];
    startupNotify = true;
    type = "Application";
    mimeType = [
      "text/plain"
      "inode/directory"
    ];
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml".text = ''
    patch:
      schema_list:
        - schema: flypy
  '';

  xdg.configFile."Code/argv.json".text = ''
    {
      "password-store": "gnome-libsecret"
    }
  '';

  xdg.configFile."darkman/config.yaml".text = ''
    dbusserver: true
    portal: true
  '';

  xdg.configFile."darkman/dark-mode.d/10-theme.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-theme true
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
      systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service || true
    '';
  };

  xdg.configFile."darkman/light-mode.d/10-theme.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-application-prefer-dark-theme false
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
      systemctl --user try-restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service || true
    '';
  };
}
