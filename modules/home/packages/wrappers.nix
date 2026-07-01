{ pkgs, lib, ... }:
let
  appimage-run = lib.hiPrio (
    pkgs.writeShellScriptBin "appimage-run" ''
      exec env WEBKIT_DISABLE_DMABUF_RENDERER=1 NO_AT_BRIDGE=1 ${pkgs.appimage-run}/bin/appimage-run "$@"
    ''
  );

  # Pin Brave to native Wayland explicitly. The nixpkgs wrapper only adds the
  # flaky --ozone-platform-hint=auto (from NIXOS_OZONE_WL); the explicit
  # --ozone-platform=wayland overrides it. NOTE: this does NOT fix the
  # paste-into-Brave failures -- that was the X11<->Wayland clipboard bridge
  # stealing the Wayland selection from native sources (fixed in
  # modules/home/desktop/services.nix). This override is just Wayland hardening.
  # It's a package override, not a hiPrio shell wrapper, so the .desktop launcher
  # (which execs the package's own bin/brave) gets the flag too.
  brave = pkgs.brave.override { commandLineArgs = "--ozone-platform=wayland"; };

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

  nix-ld-run = pkgs.writeShellScriptBin "nix-ld-run" ''
    set -euo pipefail

    if [ "$#" -eq 0 ]; then
      echo "usage: nix-ld-run <command> [args...]" >&2
      exit 2
    fi

    nix_ld_lib="/run/current-system/sw/share/nix-ld/lib"
    exec env \
      LD_LIBRARY_PATH="$nix_ld_lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
      NIX_LD_LIBRARY_PATH="$nix_ld_lib''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}" \
      "$@"
  '';

  burpsuite = lib.hiPrio (
    pkgs.writeShellScriptBin "burpsuite" ''
      set -euo pipefail

      burp_addon_source="/etc/nixos/assets/BurpAddon.jar"
      java_tool_options="--add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"

      if [ -n "''${BURP_UI_SCALE:-}" ]; then
        java_tool_options="$java_tool_options -Dsun.java2d.uiScale=$BURP_UI_SCALE"
      fi

      if [ -z "''${BURP_DISABLE_ADDON:-}" ] && [ -r "$burp_addon_source" ]; then
        burp_addon_runtime_dir="''${XDG_RUNTIME_DIR:-/tmp/burp-addons-$UID}/burp-addons"
        burp_addon_runtime="$burp_addon_runtime_dir/BurpAddon.jar"
        ${pkgs.coreutils}/bin/mkdir -p "$burp_addon_runtime_dir"
        ${pkgs.coreutils}/bin/chmod 700 "$burp_addon_runtime_dir"
        ${pkgs.coreutils}/bin/install -m0600 "$burp_addon_source" "$burp_addon_runtime"
        java_tool_options="$java_tool_options -javaagent:$burp_addon_runtime"
      fi

      cd "''${HOME:-/}"
      exec env \
        _JAVA_AWT_WM_NONREPARENTING="''${BURP_AWT_WM_NONREPARENTING:-1}" \
        JAVA_TOOL_OPTIONS="$java_tool_options''${JAVA_TOOL_OPTIONS:+ $JAVA_TOOL_OPTIONS}" \
        ${pkgs.burpsuite}/bin/burpsuite "$@"
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
    brave
    vscode
    wechat
    obs
    teamspeak
    telegram-desktop
    nix-ld-run
    burpsuite
    codex-b
    root-gui
  ];

  home.file.".local/share/burp/jython.jar".source = "${pkgs.jython}/jython.jar";
}
