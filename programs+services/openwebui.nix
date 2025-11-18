{ pkgs, ...}:

{
  imports = [
    ../my-addition/mcpo.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = pySelf: pySuper: {
          rapidocr-onnxruntime = pySuper.rapidocr-onnxruntime.overridePythonAttrs (old: {
            doCheck = false;
            doInstallCheck = false;
          });
        };
      };
      python3Packages = final.python3.pkgs;
    })
  ];
  
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3002;
    openFirewall = true;
  };

  services.mcpo = {
    enable = true;
    port = 3003;
    configFile = ../my-addition/mcpo-config.json;
    hotReload = true;
  };
  networking.firewall.allowedTCPPorts = [ 3002 3003 ];

  # This is for the mcpo server, many mcp servers use npx.
  # environment.systemPackages = [
  #   pkgs.nodejs
  # ];
}
