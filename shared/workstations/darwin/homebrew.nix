{ pkgs, ... }:
{
  imports = [
    ./dock
  ];

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Ghostty.app/"; }
  ];

  # Ensure homebrew binaries are in PATH so nix-darwin's generated
  # `eval "$(brew shellenv)"` in /etc/zshrc can find brew itself.
  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = [ "homebrew/cask" ];
    brews = pkgs.callPackage ./brews.nix { };
    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # masApps = {
    #   "bitwarden" = 1352778147; # 11/24/25 broken
    # };

  };
}
