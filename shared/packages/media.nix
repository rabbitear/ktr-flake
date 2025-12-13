{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Chromecast and TV related
    qt6Packages.qt6ct   # qt6 control, and I think wayland?
    qutebrowser
    galculator

    #androidplatformtools  # adb for Android TV if needed
    scrcpy             # GUI screen/control when using ADB
    avahi              # mDNS discovery support (enable service below)

    # Media tools
    bemenu
    wf-recorder
    #ffmpeg-full        # ffmpeg always fun to have around
  ];
}