{ lib, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "confirm";
        Privacy = "device";
        ControllerMode = "dual";
        DiscoverableTimeout = 180;
        PairableTimeout = 180;
      };
      Policy.AutoEnable = true;
    };
  };

  services.blueman.enable = true;

  systemd.user.services.blueman-applet.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.blueman}/bin/blueman-applet"
  ];
}
