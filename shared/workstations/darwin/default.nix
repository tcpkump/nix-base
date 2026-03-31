{ user, ... }:
{
  system.primaryUser = user;

  # home-manager's common module sets home.homeDirectory from
  # config.users.users.<name>.home, which is null on Darwin by default
  # (unlike NixOS which defaults to /home/<user>). Setting it here
  # ensures home-manager sees a valid absolute path.
  users.users.${user} = {
    home = "/Users/${user}";
  };
}
