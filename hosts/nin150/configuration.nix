# ktr - added flatpak
# most of the packages are on user, maybe less for others to run.
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nin150"; # Define your hostname.
  networking.networkmanager.enable = true;

   time.timeZone = "America/Anchorage";
   system.stateVersion = "25.05"; # Did you read the comment?
 }
