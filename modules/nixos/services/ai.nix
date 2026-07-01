{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 52001;
  };

  # open-webui 0.9.x runs under DynamicUser with ProtectHome=true and no HOME
  # set, so Python's Path.home() aborts with "Could not determine home
  # directory". Point HOME at the service's own StateDirectory.
  systemd.services.open-webui.environment.HOME = "/var/lib/open-webui";
}
