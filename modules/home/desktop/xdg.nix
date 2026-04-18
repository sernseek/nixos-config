{ ... }:
let
  browser = "brave-browser.desktop";
  browserMimes = {
    "text/html" = [ browser ];
    "application/xhtml+xml" = [ browser ];
    "application/x-extension-htm" = [ browser ];
    "application/x-extension-html" = [ browser ];
    "application/x-extension-shtml" = [ browser ];
    "application/x-extension-xhtml" = [ browser ];
    "application/x-extension-xht" = [ browser ];
    "x-scheme-handler/about" = [ browser ];
    "x-scheme-handler/chrome" = [ browser ];
    "x-scheme-handler/chromium" = [ browser ];
    "x-scheme-handler/ftp" = [ browser ];
    "x-scheme-handler/http" = [ browser ];
    "x-scheme-handler/https" = [ browser ];
    "x-scheme-handler/webcal" = [ browser ];
    "x-scheme-handler/unknown" = [ browser ];
  };
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = browserMimes // {
      "inode/directory" = [ "thunar.desktop" ];
    };
    associations.added = browserMimes;
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml".text = ''
    patch:
      schema_list:
        - schema: flypy
  '';
}
