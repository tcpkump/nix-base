{ ... }:
{
  home.file = {
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
