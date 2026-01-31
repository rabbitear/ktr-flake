{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pyradio
    qalculate-qt
    chromium
    ungoogled-chromium

    # Other tools
    flatpak
    flatpak-xdg-utils
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr
    game-devices-udev-rules
    gamescope

    # Utils
    mcp-nixos
    zmap

    # Testing and docs
    tldr-hs
    tldr
    iperf3
    qemu

    # Looking for music
    audacious
    audacious-plugins
  ];
}
