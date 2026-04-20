{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      # Saves/restores video memory across S3 so the GPU wakes up cleanly
      # instead of hitting "Flip event timeout on head 0". Requires
      # hardware.nvidia.open = true on driver 560+, otherwise GUI fails to
      # start after rebuild (learned the hard way).
      enable = true;
      finegrained = false;
    };
    # NVIDIA open kernel modules (still proprietary userspace). Required for
    # suspend/resume + powerManagement to work on driver 560+ for Turing/Ada.
    # Our RTX 4070 Mobile (Ada) is officially supported.
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };
}
