{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    helix
    icu
    ollama-cuda
    openssl
    vim
    wget
    zoxide
    nixd
    nixfmt
    nix-alien
  ];
}
