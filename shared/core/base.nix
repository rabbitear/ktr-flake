{ config, pkgs, ... }:

{
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
  #sound.mediaKeys = true;
  services.actkbd.enable = true;
  services.actkbd.bindings = [
    # Mute
    { keys = [ 113 ]; events = [ "key" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
    }
    # Volume down
    { keys = [ 114 ]; events = [ "key" "rep" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1- unmute";
    }
    # Volume up
    { keys = [ 115 ]; events = [ "key" "rep" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1+ unmute";
    }
    # Mic Mute
    { keys = [ 190 ]; events = [ "key" ];
      command = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
    }
  ];



  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzV4VriIYwSvx8e3Pq2hKjJDPsyj1hJAgrsiXJG/BVR kreator@theshack"
    ];
  };

  # Editor configuration
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  environment.etc."profile.d/aikey.sh".text = ''
    export OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
    export HF_TOKEN="$(cat ${config.sops.secrets.huggingface1_api_key.path})"
    export GEMINI_API_KEY="$(cat ${config.sops.secrets.gemini_api_key.path})"
    export CONTTEXT7_API_KEY="$(cat ${config.sops.secrets.context7_api_key.path})"
    export COPILOT_API_KEY="$(cat ${config.sops.secrets.copilot_api_key.path})"
  '';

  # Enable local bin path
  environment.localBinInPath = true;
}
