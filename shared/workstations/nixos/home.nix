{ user, ... }:
{
  home.homeDirectory = "/home/${user}";
  home.file = {
    ".config/k9s" = {
      source = ../all/config/k9s;
      recursive = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "default-web-browser" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

  services.ssh-agent.enable = true;

  programs = {
    tmux = {
      extraConfig = ''
        ${builtins.readFile ../all/config/tmux.conf}
        ${builtins.readFile ./config/tmux.conf}
      '';
    };

    # ghostty settings defined in shared/workstations/all/home.nix
    ghostty.enable = true;
  };
}
