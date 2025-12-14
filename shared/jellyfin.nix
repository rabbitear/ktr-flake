{ config, pkgs, lib, ... }:
{
  services.jellyfin = {
    enable = true;
    #user "kreator"
    openFirewall = ture;    
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
