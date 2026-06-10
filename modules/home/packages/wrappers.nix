{ pkgs, lib, ... }:
let
  appimage-run = lib.hiPrio (
    pkgs.writeShellScriptBin "appimage-run" ''
      exec env WEBKIT_DISABLE_DMABUF_RENDERER=1 NO_AT_BRIDGE=1 ${pkgs.appimage-run}/bin/appimage-run "$@"
    ''
  );

  vscode = lib.hiPrio (
    pkgs.writeShellScriptBin "code" ''
      exec ${pkgs.vscode}/bin/code --password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-gpu "$@"
    ''
  );

  wechat = lib.hiPrio (
    pkgs.writeShellScriptBin "wechat" ''
      exec env QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx ${pkgs.wechat}/bin/wechat "$@"
    ''
  );

  obs = lib.hiPrio (
    pkgs.writeShellScriptBin "obs" ''
      exec env LD_LIBRARY_PATH="/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" ${pkgs.obs-studio}/bin/obs "$@"
    ''
  );

  teamspeak = lib.hiPrio (
    pkgs.writeShellScriptBin "TeamSpeak" ''
      exec env LD_LIBRARY_PATH="${
        pkgs.lib.makeLibraryPath [ pkgs.gcc-unwrapped.lib ]
      }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" ${pkgs.teamspeak6-client}/bin/TeamSpeak "$@"
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

  codex-b = pkgs.writeShellScriptBin "codex-b" ''
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.codex-b"
    exec env \
      CODEX_HOME="$HOME/.codex-b" \
      HTTP_PROXY=socks5h://127.0.0.1:7891 \
      HTTPS_PROXY=socks5h://127.0.0.1:7891 \
      ALL_PROXY=socks5h://127.0.0.1:7891 \
      ${pkgs.codex}/bin/codex "$@"
  '';

  root-gui = pkgs.writeShellScriptBin "root-gui" ''
    set -euo pipefail

    if [ "$#" -eq 0 ]; then
      echo "usage: root-gui <command> [args...]" >&2
      exit 2
    fi

    if [ -z "''${DISPLAY:-}" ]; then
      echo "root-gui needs an XWayland DISPLAY, but DISPLAY is empty." >&2
      exit 1
    fi

    command_name="$1"
    shift
    case "$command_name" in
      */*) command_path="$command_name" ;;
      *)
        command_path="$(command -v "$command_name" || true)"
        if [ -z "$command_path" ]; then
          echo "root-gui: command not found: $command_name" >&2
          exit 127
        fi
        ;;
    esac

    ${pkgs.xhost}/bin/xhost +SI:localuser:root >/dev/null
    cleanup() {
      ${pkgs.xhost}/bin/xhost -SI:localuser:root >/dev/null 2>&1 || true
    }
    trap cleanup EXIT

    exec sudo --preserve-env=DISPLAY env \
      -u WAYLAND_DISPLAY \
      -u LD_LIBRARY_PATH \
      -u GIO_EXTRA_MODULES \
      -u GIO_MODULE_DIR \
      -u GI_TYPELIB_PATH \
      -u GTK_PATH \
      GDK_BACKEND=x11 \
      QT_QPA_PLATFORM=xcb \
      NO_AT_BRIDGE=1 \
      "$command_path" "$@"
  '';
in
{
  home.packages = [
    appimage-run
    vscode
    wechat
    obs
    teamspeak
    telegram-desktop
    codex-b
    root-gui
  ];
}
