{ config, pkgs, ... }:

{
  imports = [
    ./core-cli-utils.nix
    ./essential-tuis.nix
    ./core-tools.nix
    ./packages/desktop.nix
    ./packages/media.nix
    ./packages/utils.nix
    ./helix-and-lsps.nix
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

  # Add tailscale to your system packages
  environment.systemPackages = [ pkgs.tailscale ];

  # Create a oneshot to autoconnect on rebuild/switch
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
  
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
  
    serviceConfig = {
      Type = "oneshot";
  
      # Pass our tailscale auth key from sops as a Environmental Variable
      EnvironmentFile = config.sops.secrets.tailscale_preauth.path;
    };
  
    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2
  
      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi
  
      # otherwise authenticate with tailscale using the key from secrets
      ${tailscale}/bin/tailscale up -authkey "$TAILSCALE_AUTH_KEY" --accept-routes=true --reset
    '';
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
    # 3003 - miniflux
    # 27036 - steam
    allowedTCPPorts = [22 3001 3002 3003 27036];
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


}
