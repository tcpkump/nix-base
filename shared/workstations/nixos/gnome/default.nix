{
  lib,
  ...
}:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = false;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          show-battery-percentage = true;
          clock-format = "12h";
          enable-hot-corners = false;
        };

        "org/gnome/settings-daemon/plugins/power" = {
          ambient-enabled = false;
        };

        "org/gnome/shell" = {
          favorite-apps = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        };

        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
          dynamic-workspaces = false;
        };

        "org/gnome/desktop/wm/preferences" = {
          num-workspaces = lib.gvariant.mkInt32 9;
        };

        "org/gnome/desktop/wm/keybindings" = {
          # Workspace switching
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];

          # Move windows to workspaces
          move-to-workspace-1 = [ "<Super><Shift>1" ];
          move-to-workspace-2 = [ "<Super><Shift>2" ];
          move-to-workspace-3 = [ "<Super><Shift>3" ];
          move-to-workspace-4 = [ "<Super><Shift>4" ];
          move-to-workspace-5 = [ "<Super><Shift>5" ];
          move-to-workspace-6 = [ "<Super><Shift>6" ];
          move-to-workspace-7 = [ "<Super><Shift>7" ];
          move-to-workspace-8 = [ "<Super><Shift>8" ];
          move-to-workspace-9 = [ "<Super><Shift>9" ];

          # Window management
          close = [ "<Super><Shift>q" ];
          toggle-fullscreen = [ "<Super>f" ];
        };

        "org/gnome/shell/keybindings" = {
          # Disable default app shortcuts to avoid conflicts
          switch-to-application-1 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-2 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-3 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-4 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-5 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-6 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-7 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-8 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          switch-to-application-9 = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        };

        # Custom keybindings for applications
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Terminal";
          command = "ghostty";
          binding = "<Super>Return";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "File Manager";
          command = "nautilus";
          binding = "<Super>e";
        };
      };
    }
  ];
}
