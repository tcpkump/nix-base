{ ... }:
{
  # NixOS-specific base configuration

  # SSH security: root login with keys only, no password authentication
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
}
