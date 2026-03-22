{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fish
    git
    helix
    vim
    wget
    zoxide
    nixd
    nixfmt
    nix-alien
  ];
}
