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
    rc = {
      theme = {
        name = "nord";
        cornerRadius = 8;
        font = {
          "@name" = "FiraCode";
          "@size" = "11";
        };
      };
      keyboard = {
        default = true;
        keybind = [
          # <keybind key="W-Return"><action command="foot" name="Execute"></action></keybind>
          {
            "@key" = "W-Return";
            action = {
              "@name" = "Execute";
              "@command" = "alacrity";
            };
          }
          # <keybind key="W-Esc"><action command="loot" name="Execute"></action></keybind>
          {
            "@key" = "W-d";
            action = {
              "@name" = "Execute";
              "@command" = "fuzzel";
            };
          }
        ];
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot";
        layer = "overlay";
      };
      colors.background = "0f0f0f0f";
    };
  };
}
