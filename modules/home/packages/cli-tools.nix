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
    seahorse

    # nix related
    nix-output-monitor

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
