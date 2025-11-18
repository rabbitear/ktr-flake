{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    swaybg
    fuzzel
    grim
    slurp
    libnotify
    wl-clipboard
  ];

  services.mako = {
    enable = true;
    settings = {
      "actionable=true" = {
        anchor = "top-left";
      };
      actions = true;
      anchor = "top-right";
      background-color = "#000000";
      border-color = "#FFFFAA";
      border-radius = 0;
      default-timeout = 0;
      font = "monospace 10";
      height = 100;
      icons = true;
      ignore-timeout = false;
      layer = "top";
      margin = 10;
      markup = true;
      width = 300;
    };
  };

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
              "@command" = "alacritty";
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
          # Magnifier
          {
            "@key" = "W-z";
            action = {
              "@name" = "Execute";
              "@command" = "hyprmagnifier";
            };
          }
          # Screenshots
          {
            "@key" = "W-y";
            action = {
              "@name" = "Execute";
              "@command" = "bash -c grim -g $(slurp) $HOME/Pictures/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png";
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
