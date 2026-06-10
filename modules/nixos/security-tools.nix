{
  lib,
  pkgs,
  tinja-src,
  ...
}:
let
  john = pkgs.john.overrideAttrs (old: {
    src = old.src.overrideAttrs {
      outputHash = "sha256-zO1/KUJe3LvYCGlwVpNg5uDwPRD0ql/7anErb7tywC0=";
    };
  });
  seclistsPath = "${pkgs.seclists}/share/wordlists/seclists";
  tinja = pkgs.buildGoModule {
    pname = "tinja";
    version = "unstable";

    src = tinja-src;
    vendorHash = "sha256-84fz393OiFhzVMJ963bTHoCY0R8AYTOfw85NFehEwnw=";

    subPackages = [ "." ];

    postInstall = ''
      ln -s $out/bin/TInjA $out/bin/tinja
    '';

    meta = {
      description = "CLI tool for testing web pages for template injection vulnerabilities";
      homepage = "https://github.com/Hackmanit/TInjA";
      license = lib.licenses.asl20;
      mainProgram = "tinja";
    };
  };
in
{
  programs.wireshark.enable = true;

  users.users.sernseek.extraGroups = [ "wireshark" ];

  systemd.tmpfiles.rules = [
    "d /var/share 0755 root root - -"
    "L+ /var/share/seclists - - - - ${seclistsPath}"
  ];

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
    seclists
    tinja
    wfuzz
    nikto
    sqlmap
    wpscan
    joomscan
    s3scanner
    shortscan

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
    legba

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
