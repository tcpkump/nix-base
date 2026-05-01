{
  user,
  pkgs,
  ...
}:
{
  imports = [
    ./swaylock/default.nix
    ./waybar/waybar.nix
    ./swappy/swappy.nix
  ];

  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  users.users.${user}.extraGroups = [ "video" ];

  home-manager.users.${user} = {
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
      checkConfig = false;
      config = {
        modifier = "Mod4";
        floating.modifier = "Mod4";
        keybindings = { };
        modes = { };
        bars = [ ];
      };
      extraConfig = builtins.readFile ./config/sway/config;
    };
    # kanshi profiles are managed from host configs at hosts/<host>/sway.nix
    services.kanshi.enable = true;

    gtk.enable = true;
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    programs.swayr = {
      enable = true;
      systemd.enable = true;
    };

    home.packages = with pkgs; [
      wl-clipboard
      wlr-randr

      # wayland screenshots
      grim
      slurp
      swappy

      # Security and authentication
      pass-wayland
      polkit_gnome

      # helper
      brightnessctl
      pavucontrol
      playerctl
      swaybg
      wev

      libappindicator # for waybar tray
    ];

    programs.wofi.enable = true;
    home.file = {
      ".config/wofi".source = ./config/wofi;
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          geometry = "500x50-5+60";
          frame_width = 2;
          frame_color = "#ff9e64";
          sort = "yes";
          font = "Hack Nerd Font Mono 10";
          line_height = 0;
          markup = "full";
          format = "<b>%a</b>\n<i>%s</i>\n%b";
          origin = "top-center";
          alignment = "center";
          vertical_alignment = "center";
          word_wrap = "no";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = true;
          browser = "firefox -new-tab";
          corner_radius = 15;
          mouse_left_click = "close_current";
          mouse_right_click = "do_action";
          mouse_middle_click = "do_action";
        };
        urgency_low = {
          background = "#2a2a37";
          foreground = "#dcd7ba";
          timeout = 5;
        };
        urgency_normal = {
          background = "#2a2a37";
          foreground = "#dcd7ba";
          timeout = 5;
        };
        urgency_critical = {
          background = "#2a2a37";
          foreground = "#c34043";
          frame_color = "#c34043";
          timeout = 0;
        };
      };
    };
    services.udiskie.enable = true;

    # set cursor size and dpi for 4k monitor
    xresources.properties = {
      "Xcursor.size" = 24;
      "Xft.dpi" = 172;
    };
  };

  # for udiskie
  services.udisks2.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "sway 2>&1 | tee /tmp/sway.log";
        user = "${user}";
      };
    };
  };

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = "wlr";
      };
    };
    wlr.enable = true;
    wlr.settings.screencast = {
      output_name = "eDP-1";
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
  };
}
