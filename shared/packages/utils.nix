{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # TUI applications
    clipse

    # Other misc tools
    flatpak
    flatpak-xdg-utils
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr

    # Utils
    mcp-nixos
    zmap
  ];
}