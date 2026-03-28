{
  user,
  pkgs,
  config,
  lib,
  ...
}:
{
  options.myModules.swaylock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swaylock configuration";
    };

    pamConfig = lib.mkOption {
      type = lib.types.str;
      default = ''
        auth include    login
      '';
      description = "PAM configuration for swaylock";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      default = ./swaylock.conf;
      description = "Path to swaylock configuration file";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install";
    };
  };

  config = lib.mkIf config.myModules.swaylock.enable {
    security.pam.services.swaylock = {
      text = config.myModules.swaylock.pamConfig;
    };

    home-manager.users.${user}.home = {
      file.".config/swaylock/config".source = config.myModules.swaylock.configFile;
      packages =
        with pkgs;
        [
          swaylock-effects
          swayidle
        ]
        ++ config.myModules.swaylock.extraPackages;
    };
  };
}
