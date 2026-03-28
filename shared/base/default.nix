{ pkgs, ... }:
{
  # Nix configuration common to all systems
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      download-buffer-size = 1000000000
      http-connections = 100
    '';
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Minimal essential packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    dnsutils
    tcpdump
  ];

  # Enable documentation
  documentation.enable = true;
  documentation.man.enable = true;
}
