{ ... }:
{
  networking.hostName = "nixos-main";
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "223.5.5.5"
    "8.8.8.8"
    "1.1.1.1"
  ];
}
