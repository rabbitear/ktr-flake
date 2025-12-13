{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # LXQT desktop environment
    lxqt.lxqt-about
    lxqt.lximage-qt
    lxqt.lxqt-panel
    lxqt.lxqt-powermanagement
    lxqt.lxqt-runner
    lxqt.lxqt-wayland-session
    lxqt.lxqt-config
    lxqt.lxqt-qtplugin
    lxqt.lxqt-themes
    lxqt.lxqt-admin
    lxqt.lxqt-archiver
    lxqt.lxqt-menu-data
    lxqt.lxqt-sudo
    lxqt.liblxqt
    lxqt.libdbusmenu-lxqt
    lxqt.qlipper
    lxqt.obconf-qt
    lxqt.qterminal
    lxqt.libsysstat
    lxqt.pcmanfm-qt
    lxqt.pavucontrol-qt
    kdePackages.layer-shell-qt
    xdg-user-dirs

    # GUI Applications
    pyradio
    qalculate-qt
    chromium
    ungoogled-chromium
  ];
}