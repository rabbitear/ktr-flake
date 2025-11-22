{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    swaybg
    fuzzel
    grim
    slurp
    libnotify
    wl-clipboard
    wlrctl
    labwc-menu-generator
  ];

# this could be a window switching script.
# that could be used in the menus
# 
# --- !/bin/bash
# input=$(wlrctl toplevel list | awk -F': ' '{print$2}' | tofi)
# wlrctl activate app_id:"${input}"

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
      "swaybg -c '#113300' >/dev/null 2>&1 &"
      "systemctl --user restart wlr-randr-setup.service &"
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
              "@name" = "ToggleMagnify";
            };
          }
          # Screenshots
          {
            "@key" = "W-y";
            action = {
              "@name" = "Execute";
              "@command" = "bash -c \"grim -g $(slurp) $HOME/Pictures/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png\"";
            };
          }
          # reset tv
          {
            "@key" = "W-r";
            action = {
              "@name" = "Execute";
              "@command" = "systemctl --user restart wlr-randr-setup.service";
            };
          }
        ];
      };
      mouse = {
        default = true;
        context = [
          {
            "@name" = "Client";
            mousebind = [
              {
                "@button" = "Middle";
                "@action" = "Press";
                action = [
                  {
                    "@name" = "ShowMenu";
                    "@menu" = "client-menu";
                  }
                ];
              }
            ];
          }
          {
            "@name" = "TitleBar";
            mousebind = [
              {
                "@button" = "Right";
                "@action" = "Press";
                action = [
                  {
                    "@name" = "ShowMenu";
                    "@menu" = "client-menu";
                  }
                ];
              }
            ];
          }
        ];
      };
      focus = {
        followMouse = true;
      };
    };
    menu = [
      {
        label = "pipemenu";
        menuId = "menu";
        execute = "/home/user/nix/scripts/pipe.sh";
      }
      ### Root Menu
      {
        menuId = "root-menu";
        label = "Root Menu";
        icon = "";
        items = [
          {
            menuId = "openbox_pipe_menu";
            icon = "xterm";
            label = "Apps...";
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot --window-size-chars=80x25 --font=monospace:size=11";
          }
          {
            label = "Alacrity";
            icon = "alacritty";
            action = {
              name = "Execute";
              command = "alacritty";
            };
          }
          {
            label = "Reconfigure";
            action = {
              name = "Reconfigure";
            };
          }
        ];
      }
      ### Client Menu
      {
        menuId = "client-menu";
        label = "Client Menu";
        icon = "";
        items = [
          {
            label = "Maximize (toggle)";
            icon = "";
            action = {
              name = "ToggleMaximize";
            };
          }
          {
            label = "Minimize (hide)";
            icon = "";
            action = {
              name = "Iconify";
            };
          }
          {
            label = "Decorations";
            action = {
              name = "ToggleDecorations";
            };
          }
          {
            label = "Always On Top";
            action = {
              name = "ToggleAlwayOnTop";
            };
          }
          ### 
          {
            label = "Close";
            action = {
              name = "Close";
            };
          }
          {
            separator = {};
          }
          {
            label = "Tools...";
            menuId = "tools";
            icon = "";
            items = [
              {
                label = "Magnify";
                icon = "search";
                action = {
                  name = "ToggleMagnify";
                };
              } 
              {
                label = "Alacritty";
                icon = "alacritty";
                action = {
                  name = "Execute";
                  command = "alacritty";
                };
              }
              {
                label = "Foot";
                icon = "foot";
                action = {
                   name = "Execute";
                   command = "foot";
                };                 
              }
              {
                menuId = "openbox_pipe_menu";
                icon = "menu";
                label = "Apps...";
                execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot --window-size-chars=80x25 --font=monospace:size=11";
              }
            ];
          }
          {
            separator = { };
          }
          {
            label = "Workspace";
            menuId = "workspace";
            icon = "";
            items = [
              {
                label = "Move Left";
                action = {
                  name = "SendToDesktop";
                  to = "left";
                };
              }
            ];
          }
        ];
      }
    ];
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot";
        layer = "overlay";
      };
      colors.background = "af0f0f3f";
    };
  };
}
