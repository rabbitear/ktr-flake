{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6Packages.qt6ct
    qutebrowser
    galculator
    gnome-podcasts
    scrcpy
    avahi
    bemenu
    wf-recorder
    vhs
  ];
}
