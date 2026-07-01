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
        credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
        credential.credentialStore = "secretservice";
        credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        credential."https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
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

    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        term = "xterm-kitty";
        hide_window_decorations = "titlebar-only";
        window_padding_width = 8;
        wheel_scroll_multiplier = 5;
        copy_on_select = "clipboard";

        # 更舒服的滚动与回看
        scrollback_lines = 10000;
        scrollback_pager_history_size = 64; # MB, 只给 pager 用
        scrollbar = "scrolled";

        # 降噪和粘贴安全
        enable_audio_bell = false;
        paste_actions = "quote-urls-at-prompt,confirm,confirm-if-large";
        strip_trailing_spaces = "smart";

        # URL / hyperlink 体验
        show_hyperlink_targets = "ctrl";
        underline_hyperlinks = "hover";

        # 关闭窗口时更稳，shell prompt 空闲窗口不计入确认
        confirm_os_window_close = "-1 count-background";
      };
      themeFile = "tokyo_night_night";
    };

    zellij = {
      enable = true;
      # enableFishIntegration = true;
      settings = {
        theme = "tokyo-night";
        show_startup_tips = false;
        simplified_ui = true;
        pane_frames = false;
        session_serialization = true;
        serialize_pane_viewport = true;
        serialization_interval = 60;
        scroll_buffer_size = 50000;
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
        pc4 = "proxychains4 -q";
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
