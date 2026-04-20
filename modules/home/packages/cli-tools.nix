{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Shell / terminal multiplexer
    fish
    zellij

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep
    jq
    yq-go
    eza
    fzf
    gh
    dust
    inetutils
    tealdeer
    uv
    ouch
    xterm
    wl-clipboard
    xsel
    ripgrep-all

    # networking tools
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    proxychains-ng

    # misc
    cowsay
    brightnessctl
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    pinentry-gnome3
    wine-wayland
    winetricks

    # nix related
    nix-output-monitor
    nix-alien

    # productivity
    glow
    fastfetch

    # monitoring
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    bottom
    htop
  ];
}
