{ ... }:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./network.nix
    ./nix-settings.nix
    ./users-shell.nix
    ./btrfs-snapshots.nix
    ./packages.nix
  ];
}
