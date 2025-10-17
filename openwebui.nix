{config, pkgs, lib, ...}:

{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3002;
    openFirewall = true;
  };

  # Add the tts package to the system environment
  environment.systemPackages = with pkgs; [
    # Include the tts package here
    tts # Assuming 'tts' is a valid package name in nixpkgs
    # If 'tts' is a specific tool or library, you might need to specify it more precisely
    # e.g., if it's part of a larger package set like 'espeak-ng' or 'flite':
    espeak-ng
    flite
  ];
}
