{ pkgs, ... }:
{
  # Ensure Snapper's expected .snapshots subvolumes exist.
  system.activationScripts.ensureSnapperSubvolumes.text = ''
    set -eu

    create_snapshots_subvolume() {
      target="$1"
      parent="$(dirname "$target")"

      if [ ! -d "$parent" ]; then
        return 0
      fi

      if [ -e "$target" ]; then
        if ${pkgs.btrfs-progs}/bin/btrfs subvolume show "$target" >/dev/null 2>&1; then
          return 0
        fi

        echo "snapper: $target exists but is not a btrfs subvolume; skipping" >&2
        return 0
      fi

      ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$target" >/dev/null
    }

    create_snapshots_subvolume "/.snapshots"
    create_snapshots_subvolume "/home/.snapshots"
  '';

  services.snapper = {
    snapshotRootOnBoot = true;
    snapshotInterval = "6h";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs = {
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "sernseek" ];

        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 8;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 3;
        TIMELINE_LIMIT_YEARLY = 0;

        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = 1800;
        NUMBER_LIMIT = 50;
        NUMBER_LIMIT_IMPORTANT = 10;
      };

      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "sernseek" ];

        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 8;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 3;
        TIMELINE_LIMIT_YEARLY = 0;

        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = 1800;
        NUMBER_LIMIT = 30;
        NUMBER_LIMIT_IMPORTANT = 5;
      };
    };
  };
}
