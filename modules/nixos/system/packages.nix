{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fish
    git
    helix
    icu
    ollama-cuda
    vim
    wget
    zoxide
    nixd
    nixfmt
    nix-alien
  ];
}
