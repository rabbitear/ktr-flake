{ config, pkgs, ... }:

{
  imports = [
    # Core system configuration
    ./core/base.nix
    ./core/security.nix
    ./core/networking.nix
    ./core/desktop.nix

    # Security services (SOPS, GPG)
    ./sops.nix

    # Programs
    ./programs/fonts.nix
    ./programs/keyd.nix
    ./programs/helix.nix

    # Packages
    ./packages/cli.nix
    ./packages/tui.nix
    ./packages/dev.nix
    ./packages/desktop.nix
    ./packages/media.nix
    ./packages/graphics.nix

    # Flatpak
    ./services/flatpak.nix
  ];

  # FIXME: this SHOULD be a module
  # 

  # ktr-
  # quick and dirty
  # https://wiki.nixos.org/wiki/Steam#Gamescope_Compositor_/_%22Boot_to_Steam_Deck%22
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.steam.gamescopeSession = true;

  # ktr- may have to remove this...
  #services.xserver.enable = false;

  # Add flatpak group to user
  users.users.kreator.extraGroups = [ "flatpak" ];

  environment.systemPackages = with pkgs; [
    piper-tts
    espeak-ng
    ffmpeg
    whisper-cpp-vulkan
    wyoming-faster-whisper
    # steam playing around, trying things
    steamcmd
  ];

  # Enable flatpak
  services.flatpak.enable = true;
}
