{ pkgs, ... }:
let
  john = pkgs.john.overrideAttrs (old: {
    src = old.src.overrideAttrs {
      outputHash = "sha256-zO1/KUJe3LvYCGlwVpNg5uDwPRD0ql/7anErb7tywC0=";
    };
  });
in
{
  programs.wireshark.enable = true;

  users.users.sernseek.extraGroups = [ "wireshark" ];

  home-manager.users.sernseek.home.packages = with pkgs; [
    # Networking helpers used in pentest workflows
    tcpdump
    netcat-gnu
    sshuttle

    # Recon
    amass
    dnsenum
    dnsrecon
    fierce
    subfinder
    naabu
    httpx
    katana
    nuclei
    whatweb
    wafw00f
    theharvester
    waybackurls
    trufflehog
    gitleaks

    # Web
    ffuf
    gobuster
    feroxbuster
    wfuzz
    nikto
    sqlmap
    wpscan
    joomscan

    # AD and Windows services
    bloodhound
    bloodhound-py
    certipy
    enum4linux
    enum4linux-ng
    evil-winrm
    kerbrute
    krb5
    netexec
    openldap
    python3Packages.impacket
    responder
    samba
    smbmap

    # Passwords
    cewl
    crunch
    hash-identifier
    hashcat
    hashcat-utils
    hashid
    hcxtools
    hydra
    john

    # Wi-Fi
    aircrack-ng
    airgeddon
    bettercap
    bully
    hcxdumptool
    hostapd
    iw
    macchanger
    mdk4
    reaverwps
    wirelesstools
    wireshark

    # Exploitation and pivoting
    burpsuite
    chisel
    ligolo-ng
    metasploit
    mitmproxy
    rlwrap
    zap

    # Reversing, forensics, and signatures
    binwalk
    chainsaw
    exiftool
    exploitdb
    foremost
    ghidra
    radare2
    rizin
    sleuthkit
    steghide
    testdisk
    volatility3
    yara
    yara-x
    zsteg

    # JWT and Git leaks
    git-dumper
    jwt-cli
    jwt-hack
    myjwt
  ];
}
