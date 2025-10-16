# ktr - added flatpak
# most of the packages are on user, maybe less for others to run.
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "yoshi"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Anchorage";

  # Path to SOPS file
  sops.defaultSopsFile = ./../../crypt/cipher.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/kreator/.config/sops/age/keys.txt";

  # Where the decrypted key should live
  sops.secrets."github_ssh_key" = {
    mode = "0600";
    owner = "kreator";
    path = "/home/kreator/.ssh/theshack";
  };

  programs.ssh = {
    extraConfig = ''
      Host github.com
        IdentityFile ~/.ssh/theshack
        IdentitiesOnly yes
    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "kreator" ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # These may not be needed...
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Hotkey? we'll see, experimental.
  services.kanata.enable = true;
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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ktr - flatpak
  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kreator = {
    isNormalUser = true;
    description = "Jon";
    extraGroups = [ "networkmanager" "wheel" "flatpak" ];
    openssh.authorizedKeys.keys = [
      # Add SSH public keys here.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzV4VriIYwSvx8e3Pq2hKjJDPsyj1hJAgrsiXJG/BVR kreator@theshack"
    ];
    packages = with pkgs; [
    #  thunderbird
      helix
      nixd
      marksman
      fzf
      bat
      glow
      nix-search-tv
      rustup
      superTuxKart
      ripgrep
      rsync
      gh
      duf
      ncdu
      mutt
      w3m
      lynx
      fd
      dmenu
      bemenu
      fuzzel
      duckdb
      abduco
      dvtm
      zip
      unzip
      gcc
      gnumake
      btop
      pass
      iotop
      iftop
      nix-ai-tools.crush
      nix-ai-tools.copilot-cli
      wl-clipboard
      kitty
      alacritty
      foot
      virt-viewer
      imv
      flameshot
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kreator";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tree
    file
    curl
    jq
    yq
    git
    findutils
    sops
    age
    dig
    nmap
    flatpak
    flatpak-xdg-utils
    xdg-desktop-portal-gnome
  ];

  # List services that you want to enable:
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    #GSK_RENDERER = "ngl";
  };
  system.stateVersion = "25.05"; # Did you read the comment?
}
