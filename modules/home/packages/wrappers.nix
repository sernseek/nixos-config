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

  # Telegram Desktop on Linux has a long-standing bug (#26782, #29946,
  # #28473) where it doesn't read xdg-portal color-scheme unless
  # QT_QPA_PLATFORMTHEME=xdgdesktopportal is set — otherwise "Follow
  # system theme" never fires at startup and Auto-Night Mode stays light.
  telegram-desktop = lib.hiPrio (
    pkgs.writeShellScriptBin "telegram-desktop" ''
      exec env QT_QPA_PLATFORMTHEME=xdgdesktopportal ${pkgs.telegram-desktop}/bin/telegram-desktop "$@"
    ''
  );
in
{
  home.packages = [
    appimage-run
    vscode
    wechat
    telegram-desktop
  ];
}
