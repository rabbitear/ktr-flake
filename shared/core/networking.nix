{ config, pkgs, ... }:

{
  # Tailscale configuration
  services.tailscale.enable = true;
  services.tailscale.interfaceName = "userspace-networking";

  nixpkgs.overlays = [
    (final: prev: {
      tailscale = prev.tailscale.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  environment.systemPackages = [ pkgs.tailscale ];

  # Create a oneshot to autoconnect on rebuild/switch
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.tailscale_preauth.path;
    };

    script = with pkgs; ''
      sleep 2
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
        exit 0
      fi
      ${tailscale}/bin/tailscale up -authkey "$TAILSCALE_AUTH_KEY" --accept-routes=true --reset
    '';
  };

  # Networking firewall
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
    allowedTCPPorts = [
      22    # ssh
      3001  # searx
      3002  # open-webui
      3003  # miniflux
      8000  # testing vllm
      8501  # streaming
      27036 # steam
    ];
  };

  # Bluetooth pairing
  services.blueman.enable = true;
}
