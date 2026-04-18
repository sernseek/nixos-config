{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "text/html" = [ "brave-browser.desktop" ];
      "application/xhtml+xml" = [ "brave-browser.desktop" ];
      "application/x-extension-htm" = [ "brave-browser.desktop" ];
      "application/x-extension-html" = [ "brave-browser.desktop" ];
      "application/x-extension-shtml" = [ "brave-browser.desktop" ];
      "application/x-extension-xhtml" = [ "brave-browser.desktop" ];
      "application/x-extension-xht" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/chrome" = [ "brave-browser.desktop" ];
      "x-scheme-handler/chromium" = [ "brave-browser.desktop" ];
      "x-scheme-handler/ftp" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/webcal" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };

    associations.added = {
      "text/html" = [ "brave-browser.desktop" ];
      "application/xhtml+xml" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/chrome" = [ "brave-browser.desktop" ];
      "x-scheme-handler/chromium" = [ "brave-browser.desktop" ];
      "x-scheme-handler/ftp" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/webcal" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml".text = ''
    patch:
      schema_list:
        - schema: flypy
  '';
}
