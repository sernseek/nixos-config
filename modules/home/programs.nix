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
      window.decorations = "None";
      window.dynamic_padding = true;
      window.padding = {
        x = 8;
        y = 8;
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
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "tokyo-night";
      show_startup_tips = false;
      simplified_ui = true;
      pane_frames = false;
    };
  };
  programs.helix.enable = true;
  programs.fish = {
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

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.vscode = {
    enable = true;
  };
  programs.tealdeer.enableAutoUpdates = true;
}
