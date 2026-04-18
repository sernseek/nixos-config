{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;
    tumbler.enable = true;
    open-webui = {
      enable = true;
      port = 52001;
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
