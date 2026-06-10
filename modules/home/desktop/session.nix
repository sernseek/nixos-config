{ ... }:
{
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.sessionSearchVariables.LD_LIBRARY_PATH = [
    "/run/current-system/sw/share/nix-ld/lib"
  ];

  home.sessionVariables = {
    BROWSER = "brave";
    EDITOR = "hx";
    VISUAL = "hx";
    NIXOS_OZONE_WL = "1";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
  };
}
