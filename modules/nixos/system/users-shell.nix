{ pkgs, ... }:
{
  users = {
    defaultUserShell = pkgs.fish;
    users = {
      sernseek = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "libvirtd"
          "kvm"
          "docker"
        ];
      };
      root.shell = pkgs.fish;
    };
  };

  programs.fish.enable = true;
  programs.dconf.enable = true;
}
