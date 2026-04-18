{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "sernseek";
          email = "115939672+sernseek@users.noreply.github.com";
          signingkey = "8D71648FFC646BD6";
        };
        init.defaultBranch = "main";
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        commit.gpgsign = true;
        tag.gpgsign = true;
        http.proxy = "socks5h://127.0.0.1:7890";
        https.proxy = "socks5h://127.0.0.1:7890";
      };
    };

    gpg.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          decorations = "None";
          dynamic_padding = true;
          padding = {
            x = 8;
            y = 8;
          };
        };
        font = {
          size = 12;
          normal.family = "JetBrainsMono Nerd Font";
          bold.family = "JetBrainsMono Nerd Font";
          italic.family = "JetBrainsMono Nerd Font";
          bold_italic.family = "JetBrainsMono Nerd Font";
        };
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
      };
      theme = "tokyo_night";
    };
    zellij = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        theme = "tokyo-night";
        show_startup_tips = false;
        simplified_ui = true;
        pane_frames = false;
      };
    };

    helix.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
        set -gx GPG_TTY (tty)
        gpg-connect-agent updatestartuptty /bye >/dev/null
      '';
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -alF --color=auto";
        la = "ls -A --color=auto";
        l = "ls -CF --color=auto";
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    vscode.enable = true;

    tealdeer.enableAutoUpdates = true;
  };
}
