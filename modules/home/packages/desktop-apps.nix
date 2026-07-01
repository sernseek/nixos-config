{ pkgs, stablePkgs, ... }:
{
  home.packages = with pkgs; [
    # Browser
    # brave is provided (with a native-Wayland override) from wrappers.nix
    firefox
    chromium
    google-chrome

    # Communication / notes
    telegram-desktop
    obsidian
    thunderbird

    # Terminal emulator
    foot
    alacritty
    ghostty
    kitty

    # Desktop components
    noctalia-shell

    # File manager / GNOME utilities
    yazi
    nautilus
    file-roller
    loupe
    papers
    gnome-text-editor
    gnome-system-monitor
    gnome-disk-utility
    baobab
    simple-scan
    sushi

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
    remmina
    discord
    teamspeak6-client
    (stablePkgs.bottles.override {
      removeWarningPopup = true;
    })
  ];
}
