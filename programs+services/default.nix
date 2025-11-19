{config, pkgs, ... }:
{
  imports = [
    ./sops.nix
    ./gpg.nix
    ./fonts.nix
    ./keyd.nix
  ];

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
  # labwc
  programs.labwc = {
    enable = true;
    package = pkgs.labwc;
  };
  # Allow GDM to run on Wyaldn instead of Xserver
  services.displayManager.gdm.wayland = true;
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  #services.displayManager.sddm.enable = false;
  #services.displayManager.ly.enable = true;
  #services.displayManager.sddm.enable = true;
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
  services.printing = {
    enable = true;
    drivers = [
      pkgs.brlaser
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];
  };

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

  programs.adb.enable = true;

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
    allowedTCPPorts = [22 3001 3002];
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
    hashedPasswordFile = config.sops.secrets.kreator.path;
    extraGroups = [ "networkmanager" "wheel" "flatpak" "video" "kvm" ];
    openssh.authorizedKeys.keys = [
      # Add SSH public keys here.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzV4VriIYwSvx8e3Pq2hKjJDPsyj1hJAgrsiXJG/BVR kreator@theshack"
    ];
    packages = with pkgs; [
    #  thunderbird
      helix
      nixd
      marksman
      go
      gopls
      golangci-lint-langserver
      delve
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
      alacritty-graphics
      alacritty-theme
      foot
      tmux
      virt-viewer
      imv
      mpv
      tldr
      bc
      kiwix
      kiwix-tools
      zim-tools
    ];
  };

  # Enable automatic login for the user.
  # Display automatic login while figuring out labwc
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kreator";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # gonna use this for Python dev envs .local/bin path
  environment.localBinInPath = true;

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
    gnupg
    gnupg1
    sops
    age

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    nmap

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # other misc tools
    flatpak
    flatpak-xdg-utils
    xdg-desktop-portal-gnome
    aria2
    caligula
    tts
    mbrola
    mbrola-voices
    espeak-ng
    mcp-nixos

    # labwc packages
    labwc-gtktheme
    labwc-tweaks-gtk 
    labwc-menu-generator
    wayland-utils
    wayland-pipewire-idle-inhibit
    egl-wayland
    hyprmagnifier

    ## Even less needed! stuff for chromecast and tv.
    vlc
    mpv                # alternative player with GUI
    mpvpaper           # total eye-candy, animated backgrounds
    chromium           # browser casting (tab/desktop)
    #androidplatformtools  # adb for Android TV if needed
    scrcpy             # GUI screen/control when using ADB
    avahi              # mDNS discovery support (enable service below)
    drm_info
    libdrm
    nvtopPackages.amd
    nvtopPackages.nvidia

    ## Even more fun stuff
    ffmpeg-full        # ffmpeg always fun to have around
    tuxguitar          # interesting...
    zmap

    ## Our ort
    (import ../my-addition/ort.nix { inherit pkgs; })
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
  environment.etc."profile.d/aikey.sh".text = ''
    export OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
    export HF_TOKEN="$(cat ${config.sops.secrets.huggingface1_api_key.path})"
    export CONTEXT7_API_KEY="$(cat ${config.sops.secrets.context7_api_key.path})"
  '';
}
