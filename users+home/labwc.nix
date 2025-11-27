{ pkgs, config, ... }:
let
  take_screenshot = pkgs.writeShellApplication {
    name = "take_screenshot";
    text = ''
      # TODO: would look cool, to have a notify-send, with the photo,
      #       if it is clicked on (notify action) than view the photo. 
      GEOMETRY="$(slurp)"
      grim -g "$GEOMETRY" - | wl-copy
    '';  
  };
  runraisehide = pkgs.writeShellApplication {
    name = "runraisehide";
    text = ''
      # runraisehide - run or raise and hide
      [[ -z "$1" ]] && echo "Usage: $0 executable" && exit 1
      # if active -> minimize
      wlrctl window find "$1" state:active && wlrctl window minimize "$1" && exit 0
      # if minimized or inactive -> give focus
      wlrctl window find "$1" state:minimized && wlrctl window focus "$1" && exit 0
      wlrctl window find "$1" state:inactive && wlrctl window focus "$1" && exit 0
      "$1" 2>&1 &
      disown
    '';
  };

in
{
  home.packages = with pkgs; [
    take_screenshot
    runraisehide
    swaybg
    fuzzel
    foot
    grim
    slurp
    libnotify
    wl-clipboard
    wlrctl
    wtype
    wev
    ydotool
    wayland-utils
    wayland-pipewire-idle-inhibit
    egl-wayland
    labwc-menu-generator
    labwc-gtktheme
    labwc-tweaks-gtk
    #(writeScriptBin "cliphist-fuzzel-img" (builtins.readFile ../my-adiion/cliphist-fuzzel-img.sh))
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

  services.gammastep = {
    enable = true;
    latitude = 61.217381;
    longitude = -149.863129;
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
    extraOptions = [
      "-max-dedupe-search"
      "10"
      "-max-items"
      "500"
    ]; 
    systemdTargets = [ config.wayland.systemd.target ];
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Monospace:size=18";
        pad = "4x4";
        gamma-correct-blending = "yes";
        #dpi-aware = "yes";
        #initial-window-size-chars = "80x25";
        #initial-window-mode = "windowed";
        initial-window-mode = "maximized";
      };
      colors = {
        foreground = "c0caf5";
        background = "1a1b26";
        
        ## Normal/regular colors (color palette 0-7)
        regular0 = "15161E";  # black
        regular1 = "f7768e";  # red
        regular2 = "9ece6a";  # green
        regular3 = "e0af68";  # yellow
        regular4 = "7aa2f7";  # blue
        regular5 = "bb9af7";  # magenta
        regular6 = "7dcfff";  # cyan
        regular7 = "a9b1d6";  # white
        
        ## Bright colors (color palette 8-15)
        bright0 = "414868";   # bright black
        bright1 = "f7768e";   # bright red
        bright2 = "9ece6a";   # bright green
        bright3 = "e0af68";   # bright yellow
        bright4 = "7aa2f7";   # bright blue
        bright5 = "bb9af7";   # bright magenta
        bright6 = "7dcfff";   # bright cyan
        bright7 = "c0caf5";   # bright white
        
        ## dimmed colors (see foot.ini(5) man page)
        dim0 = "ff9e64";
        dim1 = "db4b4b";
       
        alpha = 0.9;
      };
      mouse = {
        hide-when-typing = "yes";
      };
      csd.hide-when-maximized = "yes";
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
      "QT_QPA_PLATFORMTHEME=qt6ct"
      "GDK_DEBUG=no-portals"
    ];
    rc = {
      theme = {
        name = "nord";
        cornerRadius = 8;
        maximizedDecoration = "none";
        font = {
          "@name" = "FiraCode";
          "@size" = "11";
        };
      };
      keyboard = {
        default = true;
        repeatRate = 25;    # rate keypresses are repeated per second.
        repeatDelay = 600;  # delay before keypress are repeated in ms.
        keybind = [
          # <keybind key="W-Return"><action command="foot" name="Execute"></action></keybind>
          {
            "@key" = "W-Return";
            action = {
              "@name" = "Execute";
              "@command" = "${runraisehide}/bin/runraisehide alacritty";
            };
          }
          # Toggle foot --- TODO: give it a specific title eg: quickterm
          {
            "@key" = "A-Space";
            action = {
              "@name" = "Execute";
              "@command" = "${runraisehide}/bin/runraisehide foot";
            };
          }
          # Toggle firefox
          {
            "@key" = "W-f";
            action = {
              "@name" = "Execute";
              "@command" = "${runraisehide}/bin/runraisehide firefox";
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
          # Old Clipboard Manager
          {
            "@key" = "W-c";
            action = {
              "@name" = "Execute";
              "@command" = "${pkgs.cliphist}/bin/cliphist-fuzzel-img";
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
              "@command" = "${take_screenshot}/bin/take_screenshot";
            };
          }
          # reset tv
          # {
          #   "@key" = "W-r";
          #   action = {
          #     "@name" = "Execute";
          #     "@command" = "systemctl --user restart wlr-randr-setup.service";
          #   };
          # }
          {
            "@key" = "W-r";
            action = {
              "@name" = "Raise";
            };
          }
          # Toggle shade
          {
            "@key" = "W-s";
            action = {
              "@name" = "ToggleShade";
            };
          }
          # Hide
          {
            "@key" = "W-h";
            action = {
              "@name" = "Iconify";
            };
          }
          # Lower
          {
            "@key" = "W-l";
            action = {
              "@name" = "Lower";
            };
          }

          # Window Menu
          {
            "@key" = "W-S-m";
            action = {
              "@name" = "ShowMenu";
              "@menu" = "client-menu";
            };
          }

          # Close
          {
            "@key" = "W-q";
            action = {
              "@name" = "Close";
            };
          }
          # Maximize
          {
            "@key" = "W-m";
            action = {
              "@name" = "ToggleMaximize";
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

      windowRules = {
        windowRule = [
          {
            "@identifier" = "blender";
            "@wantAbsorbedModifierReleaseEvents" = "yes";
          }
          {
            "@identifier" = "foot";
            #"@skipTaskbar" = "yes";
            #"@skipWindowSwitcher" = "yes";
            action = {
              "@name" = "Maximize";
            };
          }
        ];
      };
      focus = {
        followMouse = true;
        followMouseRequiresMovement = false;
      };
      menu = {
        showIcons = true;
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
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot";
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
                execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot";
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
