{...}:

{
  imports = [
    ../my-addition/mcpo.nix
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
}
