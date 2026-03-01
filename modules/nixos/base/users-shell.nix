{ pkgs, ... }:
{
  users.users.sernseek = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  users.defaultUserShell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

  programs.fish.enable = true;
  programs.dconf.enable = true;
}
