{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
