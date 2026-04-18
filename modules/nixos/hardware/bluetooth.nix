{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
        Privacy = "off";
        ControllerMode = "dual";
        DiscoverableTimeout = 0;
        PairableTimeout = 0;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;

  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
}
