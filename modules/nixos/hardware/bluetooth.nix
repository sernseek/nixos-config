{ ... }:
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
      Policy.AutoEnable = true;
    };
  };

  services.blueman.enable = true;
}
