{ pkgs, ... }:
{
  # Workstation-specific configuration
  # time.timeZone = "America/Indiana/Indianapolis";
  time.timeZone = "America/Phoenix";

  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  environment.systemPackages = with pkgs; [
    gitFull
    inetutils
  ];

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };
}
