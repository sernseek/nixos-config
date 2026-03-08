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
    exec = "${pkgs.vscode}/bin/code --password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform=wayland %F";
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
}
