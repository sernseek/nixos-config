{ pkgs, lib, ... }:
let
  appimage-run = lib.hiPrio (
    pkgs.writeShellScriptBin "appimage-run" ''
      exec env WEBKIT_DISABLE_DMABUF_RENDERER=1 NO_AT_BRIDGE=1 ${pkgs.appimage-run}/bin/appimage-run "$@"
    ''
  );

  vscode = lib.hiPrio (
    pkgs.writeShellScriptBin "code" ''
      exec ${pkgs.vscode}/bin/code --password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
    ''
  );

  wechat = lib.hiPrio (
    pkgs.writeShellScriptBin "wechat" ''
      exec env QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx ${pkgs.wechat}/bin/wechat "$@"
    ''
  );
in
{
  home.packages = [
    appimage-run
    vscode
    wechat
  ];
}
