{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.keyd
  ];
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
      wheel65 = {
        ids = [ "0fac:0ade" ];
        settings = {
          main = {
            
          };
        };
      };
    }; 
  };
}
