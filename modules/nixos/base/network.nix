{ ... }:
{
  networking.hostName = "nixos-main";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.enableIPv6 = false;
  networking.nameservers = [
    "223.5.5.5"
    "119.29.29.29"
    "114.114.114.114"
  ];
}
