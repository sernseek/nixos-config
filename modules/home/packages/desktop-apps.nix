{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browser
    brave
    firefox

    # Communication / notes
    telegram-desktop
    obsidian

    # Terminal emulator
    foot
    kitty
    alacritty
    ghostty

    # Desktop components
    noctalia-shell

    # File manager
    yazi
    thunar

    # Media / viewer / recorder
    mpv
    imv
    obs-studio

    # Input method schema
    rime-ice

    # Other desktop utilities
    clash-verge-rev
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
}
