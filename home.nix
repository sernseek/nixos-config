{ ... }:
{
  imports = [
    ./modules/home/base.nix
    ./modules/home/niri
  ];

  home.username = "sernseek";
  home.homeDirectory = "/home/sernseek";
  home.stateVersion = "26.05";
}

