{ ... }:
{
  imports = [
    ./base/network.nix
    ./base/locale.nix
    ./base/nix-settings.nix
    ./base/btrfs-snapshots.nix
    ./base/users-shell.nix
    ./base/clash.nix
    ./base/packages.nix
    ./base/fonts.nix
    ./base/input-method.nix
    ./base/bluetooth.nix
    ./desktop/services.nix
  ];
}
