{ user, ... }:
let
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in
{
  home-manager.users.${user} = {
    home.file."${xdg_configHome}/swappy/config" = {
      text = builtins.readFile ./config;
    };
  };
}
