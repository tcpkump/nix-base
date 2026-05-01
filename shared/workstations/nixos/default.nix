{ pkgs, ... }:
{
  nix.optimise.automatic = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  documentation.man.cache.enable = true;

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  fonts.packages = with pkgs; [
    ubuntu-classic
    liberation_ttf
    nerd-fonts.droid-sans-mono
  ];

  hardware = {
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      logDriver = "json-file";
    };
  };

  programs = {
    # Needed for anything GTK related
    dconf.enable = true;
    virt-manager.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  hardware.graphics.enable = true;
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.blueman.enable = true;

  services.flatpak.enable = true;

  xdg.portal.enable = true;

  programs.openvpn3 = {
    enable = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # Prevent from sleeping with lid closed while charging
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
