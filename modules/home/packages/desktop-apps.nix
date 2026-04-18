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
    alacritty
    ghostty

    # Desktop components
    noctalia-shell

    # File manager
    yazi
    thunar
    kdePackages.dolphin
    kdePackages.dolphin-plugins

    # Media / viewer / recorder
    mpv
    imv
    obs-studio
    vlc

    # Security / keyring UI
    seahorse

    # Other desktop utilities
    transmission_4-gtk
    qbittorrent-enhanced
    clash-verge-rev
    wechat
    onlyoffice-desktopeditors
    zotero
    libreoffice
    wemeet
    qq
    termius
    gamescope
    tor-browser
    localsend
    appimage-run
    nautilus
    remmina
  ];
}
