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

  # Battery-only power management. AC settings are left at macOS defaults.
  # powernap: no background CPU/network activity while display is off
  # tcpkeepalive: allow TCP connections to drop during sleep (SSH drops anyway)
  # proximitywake: suppress Bluetooth-proximity wakes from iPhone/Apple Watch
  system.activationScripts.pmset-battery.text = ''
    /usr/bin/pmset -b powernap 0
    /usr/bin/pmset -b tcpkeepalive 0
    /usr/bin/pmset -b proximitywake 0
  '';
}
