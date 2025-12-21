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

  networking.hostName = "jenny"; # Define your hostname.
  networking.networkmanager.enable = true;

   time.timeZone = "America/Anchorage";
   system.stateVersion = "25.05"; # Did you read the comment?

   # Overlay to use bun baseline for AVX compatibility on older CPUs
   nixpkgs.overlays = [
     (final: prev: {
       bun = prev.bun.overrideAttrs (oldAttrs: {
         src = prev.fetchurl {
           url = "https://github.com/oven-sh/bun/releases/download/bun-v${oldAttrs.version}/bun-linux-x64-baseline.zip";
           hash = "sha256-09g9w8s63vkcfpxlvg1j9mn5kvpc1gkpnd8jy7z4i8s2jzhjjl9x";
         };
       });
     })
   ];
 }
