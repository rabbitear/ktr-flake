{ config, pkgs, ... }:

{
  imports = [
    ./sops.nix
    ./gpg.nix
    ./fonts.nix
    ./keyd.nix
  ];

  # Core CLI utilities configuration
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

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      pkgs.brlaser
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];
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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.kreator = {
    isNormalUser = true;
    description = "Jon";
    hashedPasswordFile = config.sops.secrets.kreator.path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
      "libvirtd"
      "input"
      "kvm"
      "podman"
    ];
    openssh.authorizedKeys.keys = [
      # Add SSH public keys here.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzV4VriIYwSvx8e3Pq2hKjJDPsyj1hJAgrsiXJG/BVR kreator@theshack"
    ];
  };

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

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  environment.etc."profile.d/aikey.sh".text = ''
    export OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
    export HF_TOKEN="$(cat ${config.sops.secrets.huggingface1_api_key.path})"
    export GEMINI_API_KEY="$(cat ${config.sops.secrets.gemini_api_key.path})"
    export CONTTEXT7_API_KEY="$(cat ${config.sops.secrets.context7_api_key.path})"
    export COPILOT_API_KEY="$(cat ${config.sops.secrets.copilot_api_key.path})"
  '';

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

    # system services
    bluez-experimental
    blueman

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    aria2
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # VM stuff
    cloud-utils

    # wayland power management
    wlopm

    # other misc tools
    xdg-utils
    espeak-ng

    drm_info
    libdrm
    radeontop
    pavucontrol

    # utils
    sway-audio-idle-inhibit
    bemenu
    wf-recorder

    zmap
    rsstail-py
    delta
    tig

    # testing
    iper3
  ];
}
