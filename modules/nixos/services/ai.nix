{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  services.open-webui = {
    enable = true;
    port = 52001;
  };
}
