{ pkgs, ... }:
let
  # xwayland-satellite (0.8.x) does not bridge the clipboard into XWayland(:0)
  # on this setup, so these two user services are the X11<->Wayland clipboard
  # bridge -- TEXT ONLY.
  #
  # Images/files are deliberately NOT auto-mirrored. A bidirectional mirror has
  # no notion of which side is newer, so for binary payloads it fights itself:
  # e.g. a fresh Wayland screenshot would get clobbered by a stale X11 image,
  # and wl-paste image reads could hang and block the screenshot source. Image
  # and file transfer are therefore on-demand via the Mod+Alt+V / Mod+Alt+C /
  # Mod+Alt+I keybindings, which are user-initiated and one-directional, so they
  # never clobber. xsel is also text-only and corrupts binary selections.
  #
  # Loop prevention: each direction diffs the new text against what the other
  # side already holds and skips identical writes, so a value mirrored A->B does
  # not bounce B->A forever. Reads are bounded to keep huge VMware guest copies
  # from freezing the session (X11 selection transfer is lazy).

  text_max = "524288"; # 512 KiB

  # One Wayland->XWayland(:0) text pass, called by `wl-paste --watch`.
  wl2xForward = pkgs.writeShellScript "wl2x-forward" ''
    set -u
    export PATH=${pkgs.wl-clipboard}/bin:${pkgs.xsel}/bin:${pkgs.coreutils}/bin:$PATH
    text_max="''${VMWARE_CLIPBOARD_MAX_BYTES:-${text_max}}"
    limit=$((text_max + 1))

    # Skip non-text selections (images, files) entirely; those are handled by
    # the manual keybindings to avoid clobbering.
    types=$(wl-paste --list-types 2>/dev/null) || exit 0
    case "$types" in
      *text/plain* | *UTF8_STRING* | *STRING* | *TEXT*) ;;
      *) exit 0 ;;
    esac

    new=$(mktemp) || exit 0
    cur=$(mktemp) || {
      rm -f "$new"
      exit 0
    }
    trap 'rm -f "$new" "$cur"' EXIT

    wl-paste --type text -n > "$new" 2>/dev/null || exit 0
    [ -s "$new" ] || exit 0
    [ "$(wc -c < "$new")" -le "$text_max" ] || exit 0

    timeout 1s sh -c 'env DISPLAY=:0 xsel -ob | head -c "$1" > "$2"' sh "$limit" "$cur" 2>/dev/null || : > "$cur"
    cmp -s "$new" "$cur" && exit 0
    env DISPLAY=:0 xsel -ib < "$new"
  '';

  # XWayland(:0)->Wayland text. VMware publishes Win11 guest copies to XWayland
  # asynchronously, so we wait for XFixes CLIPBOARD events (clipnotify) and retry.
  x2wlClipboardSync = pkgs.writeShellScript "x2wl-clipboard-sync" ''
    set -u
    export PATH=${pkgs.clipnotify}/bin:${pkgs.wl-clipboard}/bin:${pkgs.xsel}/bin:${pkgs.coreutils}/bin:$PATH

    text_max="''${VMWARE_CLIPBOARD_MAX_BYTES:-${text_max}}"
    limit=$((text_max + 1))

    sync_clipboard() {
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        x=$(mktemp) || return 0
        wl=$(mktemp) || {
          rm -f "$x"
          return 0
        }

        if timeout 1s sh -c 'env DISPLAY=:0 xsel -ob | head -c "$1" > "$2"' sh "$limit" "$x" 2>/dev/null && [ -s "$x" ]; then
          x_bytes=$(wc -c < "$x")
          if [ "$x_bytes" -gt "$text_max" ]; then
            echo "x2wl: skip oversized text: >= $x_bytes bytes, limit $text_max" >&2
            rm -f "$x" "$wl"
            return 0
          fi
          wl-paste --type text -n > "$wl" 2>/dev/null || : > "$wl"
          cmp -s "$x" "$wl" || wl-copy < "$x"
          rm -f "$x" "$wl"
          return 0
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

  # Wayland CLIPBOARD text -> XWayland(:0). Skips writes that already match the
  # X11 side to break the feedback loop that previously froze Wayland apps.
  systemd.user.services.wl2x-clipboard-sync = {
    Unit = {
      Description = "Sync Wayland clipboard text to XWayland (:0)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${wl2xForward}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # XWayland(:0) CLIPBOARD text -> Wayland. Bounded reads keep large VMware
  # guest copies from freezing the session.
  systemd.user.services.x2wl-clipboard-sync = {
    Unit = {
      Description = "Sync XWayland (:0) clipboard text to Wayland";
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
