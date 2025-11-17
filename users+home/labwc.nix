{ pkgs, config, ... }:
{
  wayland.windowManager.labwc = {
    enable = true;
    autostart = [
      #"wayvnc &"
      #"waybar &"
      "swaybg -c '#113344' >/dev/null 2>&1 &"
    ];
    environment = [
      "XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"
    ];
  };
}
