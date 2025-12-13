{ config, pkgs, ... }:

{
  imports = [
    ./core-cli-utils.nix
    ./essential-tuis.nix
    ./core-tools.nix
  ];

  # Enable the X11 windowing system.
  # we can't do this here, because we are across hosts!
  #services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
  services.xserver.enable = true;
  # labwc
  programs.labwc = {
    enable = true;
    package = pkgs.labwc;
  };
  # Allow GDM to run on Wyaldn instead of Xserver
  #services.displayManager.gdm.wayland = true;
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  #services.displayManager.cosmic-greeter = true;
  #services.displayManager.sddm.enable = false;
  #services.displayManager.ly.enable = true;
  #services.displayManager.sddm.enable = true;
  services.displayManager.enable = true;
  services.desktopManager.gnome.enable = true;
  # These may not be needed...
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;
  services.xserver.desktopManager.lxqt = {
    enable = true;
    iconThemePackage = pkgs.kdePackages.breeze-icons;
    extraPackages = with pkgs; [ xscreensaver ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  # Bluetooth pairing devices
  services.blueman.enable = true;

  # Tailscale :)
  services.tailscale.enable = true;
  services.tailscale.interfaceName = "userspace-networking";
  nixpkgs = {
    overlays = [
      (final: prev: {
        tailscale = prev.tailscale.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
    config = {
      allowUnfree = true;
    };
  };

  # Thinning down --- we need to clean up and trim the fat.
  #programs.adb.enable = true;

  # Networking
  # Enable SSH access in from Tailscale network 22
  # Enable http/s traffic to go through 80 and 443 for access n8n thorugh tailscale
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
    #   22 - ssh
    # 3001 - searx
    # 3002 - open-webui
    # 27036 - steam
    allowedTCPPorts = [22 3001 3002 27036];
  };

  # ktr - flatpak
  services.flatpak.enable = true;

  # Enable automatic login for the user.
  # Display automatic login while figuring out labwc
  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "kreator";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Add flatpak group to user
  users.users.kreator.extraGroups = [ "flatpak" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # I can use some of these tools in labwc
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
    lxqt.lxqt-about
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

    # tui?
    clipse

    # other misc tools
    flatpak
    flatpak-xdg-utils
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr

    ## Even less needed! stuff for chromecast and tv.
    qt6Packages.qt6ct   # qt6 control, and I think wayland?
    qutebrowser
    galculator
    
    #androidplatformtools  # adb for Android TV if needed
    scrcpy             # GUI screen/control when using ADB
    avahi              # mDNS discovery support (enable service below)

    ungoogled-chromium

    # utils
    bemenu
    wf-recorder

    ## Even more fun stuff
    #ffmpeg-full        # ffmpeg always fun to have around
    mcp-nixos
    zmap
  ];
}
