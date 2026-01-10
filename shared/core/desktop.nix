{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  # labwc
  programs.labwc = {
    enable = true;
    package = pkgs.labwc;
  };

  # Enable GDM display manager
  services.displayManager.gdm.enable = true;
  services.displayManager.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

  # LXQT desktop manager
  services.xserver.desktopManager.lxqt = {
    enable = true;
    iconThemePackage = pkgs.kdePackages.breeze-icons;
    extraPackages = with pkgs; [ xscreensaver ];
  };
}
