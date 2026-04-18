{ pkgs, ... }:
{
  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;

  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
}
