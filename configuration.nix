{ ... }:
{
  imports = [
    ./modules/nixos/boot.nix
    ./modules/nixos/base.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/desktop/niri.nix
    ./modules/nixos/desktop/steam.nix
  ];

  system.stateVersion = "26.05";
}
