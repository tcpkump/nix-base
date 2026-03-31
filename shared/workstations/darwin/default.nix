{ user, ... }:
{
  system.primaryUser = user;

  # Determinate Nix manages the Nix installation on macOS. Disable
  # nix-darwin's built-in Nix management to avoid conflicts with the
  # Determinate daemon. See: https://determinate.systems/nix/
  nix.enable = false;

  # home-manager's common module sets home.homeDirectory from
  # config.users.users.<name>.home, which is null on Darwin by default
  # (unlike NixOS which defaults to /home/<user>). Setting it here
  # ensures home-manager sees a valid absolute path.
  users.users.${user} = {
    home = "/Users/${user}";
  };
}
