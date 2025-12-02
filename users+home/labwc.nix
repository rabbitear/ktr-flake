{ pkgs, config, ... }:
let
  take_screenshot = pkgs.writeShellApplication {
    name = "take_screenshot";
    text = ''
      # TODO: would look cool, to have a notify-send, with the photo,
      #       if it is clicked on (notify action) than view the photo. 
      GEOMETRY="$(slurp)"
      grim -g "$GEOMETRY" - | wl-copy
      notify-send --expire-time=3800 "screenshot" "took screenshot"
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
  notify_send_time = pkgs.writeShellApplication {
    name = "notify_send_time";
    text = ''
      ${pkgs.libnotify}/bin/notify-send \
      --expire-time=5800 \
        "Time is:" \
        "$(date)"
    '';
  };

in
{
  home.packages = with pkgs; [
    take_screenshot
    runraisehide
    notify_send_time
    swaybg
    grim
    slurp
    qiv
    libnotify
    libsixel
    wl-clipboard
    wlrctl
    wlr-randr
    wev
    wayland-utils
    wayland-pipewire-idle-inhibit
    egl-wayland
    wofi             # testing see if works with screenshots better 
    imagemagick
    labwc-menu-generator
    labwc-gtktheme
    labwc-tweaks-gtk
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

  services.lxqt-policykit-agent.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Monospace:size=18";
        pad = "4x4";
        gamma-correct-blending = "yes";
        dpi-aware = "yes";
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
      "swaybg -c '#113300' >/dev/null 2>&1 &"
      "systemctl --user restart wlr-randr-setup.service &"
      "[[ $(hostname) == sasha ]] && wlr-randr --output HDMI-A-1 --right-of DP-4"
      "lxqt-panel >/dev/null 2>&1 &"
    ];
    environment = [
      "XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"
      "QT_QPA_PLATFORMTHEME=qt6ct"
      "GDK_DEBUG=no-portals"
      "XCURSOR_THEME=Adwaita"
      "XCURSOR_SIZE=24"
      "XKB_DEFAULT_LAYOUT=us"
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
        repeatDelay = 300;  # delay before keypress are repeated in ms.
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
            "@key" = "W-Space";
            action = {
              "@name" = "Execute";
              "@command" = "${runraisehide}/bin/runraisehide firefox";
            };
          }
          {
            "@key" = "W-k";
            action = {
              "@name" = "PreviousWindow";
            };
          }
          {
            "@key" = "W-j";
            action = {
              "@name" = "NextWindow";
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
          {
            "@key" = "W-S-c";
            action = {
              "@name" = "Execute";
              "@command" = "${pkgs.cliphist}/bin/cliphist-wofi-img";
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
          {
            "@key" = "W-x";
            action = {
              "@name" = "Execute";
              "@commnad" = "notify_send_time";
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
                    "@menu" = "window-ops";
                  }
                ];
              }
            ];
          }
          {
            "@name" = "Desktop";
            mousebind = [
              {
                "@button" = "Middle";
                "@action" = "Press";
                action = [
                  {
                    "@name" = "ToggleMagnify";
                  }
                ];
              }
            ];
          }
          {
            "@name" = "All";
            mousebind = [
              {
                "@button" = "Extra";
                "@action" = "Press";
                action = [
                  {
                    "@name" = "ToggleMagnify";
                  }
                ];
              }
            ];
          }


          {
            "@name" = "All";
            mousebind = [
              {
                "@button" = "Side";
                "@action" = "Press";
                action = [
                  {
                    "@name" = "Execute";
                    "@command" = "${take_screenshot}/bin/take_screenshot";             
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
        ignoreButtonReleasePeriod = 250;
        showIcons = true;
      };
      magnifier = {
        # with width and height use -1 for fullscreen
        width = 600;
        height = 400;
        initScale = 2;
        increment = 2.0;
        useFilter = true;
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
            label = "Magnify";
            icon = "search";
            action = {
              name = "ToggleMagnify";
            };
          }
          {
            separator = { };
          }
          {
            menuId = "openbox_pipe_menu";
            icon = "xterm";
            label = "Apps...";
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot";
          }
          {
            separator = { };
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
            label = "Kitty";
            icon = "kitty";
            action = {
              name = "Execute";
              command = "kitty";
            };
          }
          {
            separator = { };
          }
          {
            menuId = "root-utils";
            label = "Utils...";
            icon = "terminal";
            items = [ 
              {
                label = "Dismiss ALL notifications";
                icon = "mako";
                action = {
                  name = "Execute";
                  command = "makoctl dismiss --all";
                };
              }

              {
                label = "Take Screenshot";
                icon = "screenshot";
                action = {
                  "name" = "Execute";
                  "command" = "${take_screenshot}/bin/take_screenshot";             
                };
              }
              {
                separator = { };
              }
              {
                label = "Reconfigure";
                action = {
                  name = "Reconfigure";
                };
              }
            ];
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
            label = "Magnify";
            icon = "search";
            action = {
              name = "ToggleMagnify";
            };
          }
          {
            separator = { };
          }
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
            label = "Window...";
            menuId = "window-ops";
            icons = "";
            items = [
              # More window flags and actions can be added here.
              {
                label = "Fullscreen (toggle)";
                action = {
                  name = "ToggleFullscreen";
                };
              }
              {
                label = "Decorations";
                action = {
                  name = "ToggleDecorations";
                };
              }
              {
                label = "Always On Top (toggle)";
                action = {
                  name = "ToggleAlwayOnTop";
                };
              }
              {
                label = "Sticky (toggle)";
                action = {
                  name = "ToggleOmnipresent";
                };
              }
              {
                label = "Lower";
                action = {
                  name = "Lower";
                };
              }

              {
                label = "Raise";
                action = {
                  name = "Raise";
                };
              }


            ];
          }
          {
            label = "Tools...";
            menuId = "tools";
            icon = "";
            items = [
              {
                label = "Dismiss ALL notifications";
                icon = "mako";
                action = {
                  name = "Execute";
                  command = "makoctl dismiss --all";
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
            ];
          }
          {
             label = "Apps...";
             menuId = "openbox_pipe_menu";
             icon = "menu";
             execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --desktop --icons --pipemenu --terminal-prefix=${pkgs.foot}/bin/foot";
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
              {
                label = "NextWindow";
                action = {
                  name = "NextWindow";
                };
              }
              {
                label = "PreviousWindow";
                action = {
                  name = "PreviousWindow";
                };
              }
            ];
          }
          {
            separator = { };
          }
          {
            label = "Take Screenshot";
            icon = "screenshot";
            action = {
              "name" = "Execute";
              "command" = "${take_screenshot}/bin/take_screenshot";             
            };
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
        image-size-ratio = 0.8;
        dpi-aware = "no";
      };
      colors.background = "afaf00ff";
    };
  };
}
