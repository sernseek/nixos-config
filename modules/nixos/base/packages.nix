{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fish
    git
    helix
    nixfmt
    vim
    wget
  ];
}
