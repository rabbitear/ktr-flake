{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6Packages.qt6ct
    qutebrowser
    galculator
    scrcpy
    avahi
    bemenu
    wf-recorder
  ];
}
