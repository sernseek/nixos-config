{
  lib,
  dirsearch-src,
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
  dirsearch = pkgs.python3Packages.buildPythonApplication rec {
    pname = "dirsearch";
    version = "0.5.0-unstable-2026-06-11";

    src = dirsearch-src;

    pyproject = true;
    build-system = with pkgs.python3Packages; [
      setuptools
      wheel
    ];

    dependencies = with pkgs.python3Packages; [
      beautifulsoup4
      colorama
      defusedcsv
      defusedxml
      httpx
      httpx-ntlm
      jinja2
      pyopenssl
      pysocks
      requests
      requests-ntlm
      requests-toolbelt
    ];

    pythonRelaxDeps = [
      "defusedxml"
      "pyopenssl"
    ];

    pythonImportsCheck = [ "dirsearch" ];

    meta = {
      description = "Advanced web path scanner";
      homepage = "https://github.com/maurosoria/dirsearch";
      license = lib.licenses.gpl2Only;
      mainProgram = "dirsearch";
    };
  };
  seclistsPath = "${pkgs.seclists}/share/wordlists/seclists";
  sliver = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "sliver";
    version = "1.7.3";

    client = pkgs.fetchurl {
      url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-client_linux-amd64";
      hash = "sha256-sOMooTHk1nnpsmhVLbmcotRgUbkgWmf5t/fBYomD2q4=";
    };

    server = pkgs.fetchurl {
      url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-server_linux-amd64";
      hash = "sha256-4yFuzRL25+l8tFiLtthccOyjvfrYsIGP/VPMsuNXzMg=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ${client} $out/bin/sliver-client
      install -Dm755 ${server} $out/bin/sliver-server
      ln -s sliver-client $out/bin/sliver

      runHook postInstall
    '';

    meta = {
      description = "Adversary emulation framework";
      homepage = "https://github.com/BishopFox/sliver";
      license = lib.licenses.gpl3Only;
      mainProgram = "sliver-client";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };
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
    "d /usr/share 0755 root root - -"
    "L+ /usr/share/seclists - - - - ${seclistsPath}"
    "r /var/share/seclists - - - - -"
  ];

  home-manager.users.sernseek.home.packages = with pkgs; [
    # Networking helpers used in pentest workflows
    tcpdump
    netcat-gnu
    nfs-utils
    mosquitto
    rpcbind
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
    fscan

    # Web
    ffuf
    gobuster
    feroxbuster
    dirsearch
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
    sliver
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
