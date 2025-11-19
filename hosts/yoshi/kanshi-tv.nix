{ pkgs, config, lib, ... }:
{
  # Add to existing systemd.user.services
  systemd.user.services.wlr-randr-setup = lib.mkIf (config.networking.hostName == "Yoshi") {
    description = "Set TV display mode";
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --mode 1920x1080@60";
    };
  };

  environment.systemPackages = [ pkgs.wlr-randr ];  # Still required
}
