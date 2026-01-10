{ config, pkgs, lib, ... }:
{
  services.jellyfin = {
    enable = true;
    #user "kreator"
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
