{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings.user.name = "sernseek";
    settings.user.email = "115939672+sernseek@users.noreply.github.com";
    settings.user.signingkey = "8D71648FFC646BD6";
    settings.init.defaultBranch = "main";
    settings.gpg.program = "${pkgs.gnupg}/bin/gpg";
    settings.commit.gpgsign = true;
    settings.tag.gpgsign = true;
    settings.http.proxy = "socks5h://127.0.0.1:7890";
    settings.https.proxy = "socks5h://127.0.0.1:7890";
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.helix.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx GPG_TTY (tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null
    '';
    shellAliases = {
      code = "code --password-store=gnome-libsecret";
      ls = "ls --color=auto";
      ll = "ls -alF --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";
    };
  };
}
