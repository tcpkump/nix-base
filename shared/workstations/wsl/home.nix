{ ... }:
{
  home.file = {
    ".config/lazygit" = {
      source = ../all/config/lazygit;
      recursive = true;
    };
    ".config/k9s" = {
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
  };
}
