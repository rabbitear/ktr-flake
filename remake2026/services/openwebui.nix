{ config, pkgs, ...}:

{
  # imports = [
  #   ../my-addition/mcpo.nix
  # ];

  #nixpkgs.overlays = [
  #  (final: prev: {
  #    python3 = prev.python3.override {
  #      packageOverrides = pySelf: pySuper: {
  #        rapidocr-onnxruntime = pySuper.rapidocr-onnxruntime.overridePythonAttrs (old: {
  #          doCheck = false;
  #          doInstallCheck = false;
  #        });
  #      };
  #    };
  #    python3Packages = final.python3.pkgs;
  #  })
  #];
  
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3002;
    openFirewall = true;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        #(builtins.fetchGit {
        #  url = "https://github.com/tailscale/caddy-tailscale.git";
        #  rev = "v0.0.0-20250207163903-69a970c84556";
        #  #sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
        #  sha256 = "sha256-OydhzUGG3SUNeGXAsB9nqXtnwvD36+2p3QzDtU4YyFg=";
        #})
         
        #"github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
        (builtins.fetchTree {
          type = "github";
          #url = "https://github.com/tailscale/caddy-tailscale.git";
          repo = "caddy-tailscale";
          owner = "tailscale";
          # bot tells me to do these 2 instead...
          rev = "v0.0.0-20250207163903-69a970c84556";
          narHash = "sha256-OydhzUGG3SUNeGXAsB9nqXtnwvD36+2p3QzDtU4YyFg=";
          #narHash = "sha256-YUHq69igcvFecLLYhnGv2cr24hYA5hrdxH0n53c0EL0=";
        })
      ];
    };
    virtualHosts."https://sasha:3442".extraConfig = ''
      bind tailscale/sasha
      reverse_proxy localhost:3002
    '';
  };

  # networking.firewall.allowedTCPPorts = [ 3002 3004 ];
  networking.firewall.allowedTCPPorts = [ 3002 ];
  # EOF?
}
