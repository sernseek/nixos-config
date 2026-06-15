{ pkgs, ... }:
let
  # Wayland → XWayland(:0) clipboard sync with content dedup to avoid the
  # feedback loop that kills the Wayland selection after a few hours.
  wl2xClipboardSync = pkgs.writeShellScript "wl2x-clipboard-sync" ''
    set -u
    export PATH=${pkgs.wl-clipboard}/bin:${pkgs.xsel}/bin:${pkgs.coreutils}/bin:$PATH
    # Text only. Images are binary and xsel is text-only — piping image data
    # through it corrupts the X11 selection and triggers satellite to steal
    # the source Wayland app's selection, freezing it.
    exec wl-paste --type text --watch sh -c '
      wl=$(mktemp) || exit 0
      x=$(mktemp) || { rm -f "$wl"; exit 0; }
      trap "rm -f \"$wl\" \"$x\"" EXIT
      wl-paste --type text -n > "$wl" 2>/dev/null || exit 0
      [ -s "$wl" ] || exit 0
      DISPLAY=:0 xsel -ob > "$x" 2>/dev/null || true
      cmp -s "$wl" "$x" && exit 0
      DISPLAY=:0 xsel -ib < "$wl"
    '
  '';

  # VMware publishes Win11 guest copies to XWayland asynchronously. Wait for
  # XFixes CLIPBOARD events, then copy only small text payloads into Wayland.
  # The bounded read is important: X11 clipboard transfer is lazy, so reading
  # the whole selection just to check its size can freeze VMware on huge text.
  x2wlClipboardSync = pkgs.writeShellScript "x2wl-clipboard-sync" ''
    set -u
    export PATH=${pkgs.clipnotify}/bin:${pkgs.wl-clipboard}/bin:${pkgs.xsel}/bin:${pkgs.coreutils}/bin:$PATH

    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/x2wl-clipboard-sync"
    mkdir -p "$state_dir"
    last_x="$state_dir/last-x"
    max_bytes="''${VMWARE_CLIPBOARD_MAX_BYTES:-524288}"
    limit_bytes=$((max_bytes + 1))
    : > "$last_x"

    sync_clipboard() {
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        x=$(mktemp) || return 0
        wl=$(mktemp) || {
          rm -f "$x"
          return 0
        }

        if timeout 1s sh -c 'env DISPLAY=:0 xsel -ob | head -c "$1" > "$2"' sh "$limit_bytes" "$x" 2>/dev/null && [ -s "$x" ]; then
          x_bytes=$(wc -c < "$x" || echo 0)
          if [ "$x_bytes" -gt "$max_bytes" ]; then
            echo "x2wl-clipboard-sync: skip oversized clipboard: >= $x_bytes bytes, limit $max_bytes bytes" >&2
            rm -f "$x" "$wl"
            return 0
          fi

          if ! cmp -s "$x" "$last_x"; then
            wl-paste --type text -n > "$wl" 2>/dev/null || : > "$wl"
            if ! cmp -s "$x" "$wl"; then
              wl-copy < "$x"
            fi
            cp "$x" "$last_x"
            rm -f "$x" "$wl"
            return 0
          fi
        fi

        rm -f "$x" "$wl"
        sleep 0.1
      done
    }

    sync_clipboard
    while env DISPLAY=:0 clipnotify; do
      sync_clipboard
    done
  '';

in
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Pushes Wayland CLIPBOARD → XWayland(:0) on every change, skipping writes
  # when the X11 selection already matches — breaks the satellite feedback loop
  # that previously froze Wayland apps after a few hours.
  systemd.user.services.wl2x-clipboard-sync = {
    Unit = {
      Description = "Sync Wayland clipboard to XWayland (:0)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${wl2xClipboardSync}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Pull small XWayland(:0) CLIPBOARD text payloads into Wayland after XFixes
  # clipboard events. Large VMware guest copies are skipped to avoid freezes.
  systemd.user.services.x2wl-clipboard-sync = {
    Unit = {
      Description = "Sync small XWayland (:0) clipboard text to Wayland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${x2wlClipboardSync}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.startServices = "sd-switch";
}
