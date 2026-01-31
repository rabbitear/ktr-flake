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
            volumeup = "command(wpctl set-volume @DEFAULT_SINK@ 5%+)";
            volumedown = "command(wpctl set-volume @DEFAULT_SINK@ 5%-)";
          };
        };
      };
    }; 
  };
}
