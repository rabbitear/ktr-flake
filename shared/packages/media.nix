{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6Packages.qt6ct
    qutebrowser
    #galculator # broke compile, fix later
    gnome-podcasts
    scrcpy
    avahi
    bemenu
    wf-recorder
    vhs
  ];
}
