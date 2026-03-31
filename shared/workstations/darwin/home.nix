{ user, ... }:
{
  home.homeDirectory = "/Users/${user}";
  home.file = {
    "./Library/Application Support/lazygit" = {
      source = ../all/config/lazygit;
      recursive = true;
    };
    "./Library/Application Support/k9s" = {
      source = ../all/config/k9s;
      recursive = true;
    };
  };

  programs = {
    tmux = {
      extraConfig = ''
        ${builtins.readFile ../all/config/tmux.conf}
        ${builtins.readFile ./config/tmux.conf}
      '';
    };

    # ghostty installed via homebrew cask, configured via shared/workstations/all/home.nix
    ghostty = {
      enable = true;
      # Override package to null since we install via homebrew
      package = null;
    };

    # keeping alacritty as backup terminal emulator
    alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Block";
        };

        window = {
          opacity = 1.0;
          padding = {
            x = 4;
            y = 4;
          };
          option_as_alt = "OnlyLeft";
        };

        font = {
          normal = {
            family = "Hack Nerd Font Mono";
            style = "Regular";
          };
          size = 14;
        };

        env = {
          TERM = "xterm-256color";
        };

        # kanagawa wave theme
        colors = {
          primary = {
            background = "0x1f1f28";
            foreground = "0xdcd7ba";
          };

          normal = {
            black = "0x090618";
            red = "0xc34043";
            green = "0x76946a";
            yellow = "0xc0a36e";
            blue = "0x7e9cd8";
            magenta = "0x957fb8";
            cyan = "0x6a9589";
            white = "0xc8c093";
          };

          bright = {
            black = "0x727169";
            red = "0xe82424";
            green = "0x98bb6c";
            yellow = "0xe6c384";
            blue = "0x7fb4ca";
            magenta = "0x938aa9";
            cyan = "0x7aa89f";
            white = "0xdcd7ba";
          };
        };
      };
    };
  };
}
