{ pkgs, ... }:
{
  systemd.services.numlock-on-tty = {
    description = "Enable NumLock on all TTYs";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-user-sessions.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      for tty in /dev/tty{1..6}; do
        ${pkgs.kbd}/bin/setleds -D +num < "$tty" > /dev/null
      done
    '';
  };
}
