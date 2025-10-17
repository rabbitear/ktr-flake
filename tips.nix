# From the Article:
# <http://aurelioflorez.com/2025/06/25/Serve-n8n-publicly-with-nixOS/>
# A bunch of different tips I want to probably add to my flake.

{config, pkgs, lib, ...}:

{
  ###############################
  # SSH configs
  # programs.ssh.startAgent = true;
  
  # # Add github and public facing server keys every time
  
  # users.users.server.openssh.authorizedKeys.keys = [
  #   "/home/server/.ssh/github.pub"
  #   "/home/server/.ssh/vultr.pub"
  #];
  
  # Enable the OpenSSH daemon.
  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    PasswordAuthentication = false; # only key pairs 🔑
  #    PrintMotd = true;
  #  };
  #};
  
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime-increment.enable = true;
    ignoreIP = [
      "127.0.0.1/8" # local machine traffic
      "10.0.0.174" # local network traffic
      "100.67.201.23" # local tailscale traffic
    ];
  };
  
  ################################
  # Enable Tailscale
  #services.tailscale.enable = true;
  
  # Networking
  # Enable SSH access in from Tailscale network 22
  # Enable http/s traffic to go through 80 and 443 for access n8n thorugh tailscale
  # networking.firewall = {
    # enable = true;
    # trustedInterfaces = ["tailscale0"];
    # allowedUDPPorts = [config.services.tailscale.port];
    # allowedTCPPorts = [22 443 80];
  # };
  
  ###############################
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;
  # ktr - this is not supported with flakes
}
  
