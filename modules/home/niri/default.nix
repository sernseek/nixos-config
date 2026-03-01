{ pkgs, config, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
  localNiriConfPath = "/etc/nixos/modules/home/niri/conf";
  noctaliaIpc = pkgs.writeShellScriptBin "noctalia-ipc" ''
    set -eu

    running_shell_path="$(${pkgs.procps}/bin/ps -eo args | ${pkgs.gnused}/bin/sed -n 's#.* -p \(/nix/store/[^ ]*-noctalia-shell-[^ ]*/share/noctalia-shell\).*#\1#p' | ${pkgs.coreutils}/bin/head -n1)"

    if [ -n "$running_shell_path" ] && [ -x "''${running_shell_path%/share/noctalia-shell}/bin/noctalia-shell" ]; then
      exec "''${running_shell_path%/share/noctalia-shell}/bin/noctalia-shell" ipc call "$@"
    fi

    exec /etc/profiles/per-user/${config.home.username}/bin/noctalia-shell ipc call "$@"
  '';
in
{
  home.packages = with pkgs; [
    # Niri v25.08+ uses on-demand Xwayland via xwayland-satellite.
    xwayland-satellite
    noctaliaIpc
  ];

  xdg.configFile = {
    "niri/config.kdl".source = mkSymlink "${localNiriConfPath}/config.kdl";
    "niri/keybindings.kdl".source = mkSymlink "${localNiriConfPath}/keybindings.kdl";
    "niri/noctalia-shell.kdl".source = mkSymlink "${localNiriConfPath}/noctalia-shell.kdl";
    "niri/spawn-at-startup.kdl".source = mkSymlink "${localNiriConfPath}/spawn-at-startup.kdl";
    "niri/niri-hardware.kdl".source = ./niri-hardware.kdl;
  };

  home.file.".wayland-session" = {
    source = pkgs.writeScript "init-session" ''
      systemctl --user is-active niri.service && systemctl --user stop niri.service
      /run/current-system/sw/bin/niri-session
    '';
    executable = true;
  };

  systemd.user.services.niri-flake-polkit = {
    Unit = {
      Description = "PolicyKit Authentication Agent provided by niri-flake";
      After = [
        "graphical-session.target"
      ];
      Wants = [ "graphical-session-pre.target" ];
    };
    Install.WantedBy = [ "niri.service" ];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle manager for niri (auto lock)";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      PartOf = [ "niri.service" ];
    };
    Install.WantedBy = [ "niri.service" ];
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 600 "/etc/profiles/per-user/${config.home.username}/bin/noctalia-ipc lockScreen lock" \
          timeout 630 "/run/current-system/sw/bin/niri msg action power-off-monitors" \
          before-sleep "/etc/profiles/per-user/${config.home.username}/bin/noctalia-ipc lockScreen lock"
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
