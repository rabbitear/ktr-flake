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

  # Add flatpak group to user
  users.users.kreator.extraGroups = [ "flatpak" ];

  # Enable flatpak
  services.flatpak.enable = true;
}
