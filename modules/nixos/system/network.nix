{ ... }:
let
  openPorts = [
    8080
    53317
    2233
  ];
in
{
  networking = {
    hostName = "nixos-main";
    enableIPv6 = false;

    networkmanager = {
      enable = true;
      dns = "none";
    };

    nameservers = [
      "223.5.5.5"
      "119.29.29.29"
      "114.114.114.114"
    ];

    firewall = {
      enable = true;
      allowedTCPPorts = openPorts;
      allowedUDPPorts = openPorts;
    };
  };
}
