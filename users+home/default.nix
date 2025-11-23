{ config, lib, pkgs, ... }:
let
  duckduckgo-search = pkgs.writeShellApplication {
    name = "duckduckgo-search";
    text = ''
      #!/bin/sh
      query="$*"
      if [ -z "$query" ]; then
        echo "Usage: ? <search terms>"
        exit 1
      fi
      w3m -o editor=hx -o confirm_qq=no "https://duckduckgo.com/lite?q=$query"
    '';
  };
in

{
  imports = [
    ../my-addition/journal-module.nix
    ../my-addition/printer-module.nix
    ../my-addition/ingest-module.nix
    ./gnome.nix
    ./mutt.nix
    ./sync-jrnl.nix
    ./labwc.nix
    ./kanshi.nix
  ];

  # My shell scripts.
  systemd.user.enable = true;
  programs.journal.enable = true;
  programs.journal.remoterepository = "";
  programs.printer.enable = true;
  programs.ingest-to-journal.enable = true;

  home.packages = [
    duckduckgo-search
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fantasque-sans-mono
    pkgs.keychain       # for our ssh server
    pkgs.devenv
  ];
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  home.file.".config/ort.json".text = ''
    {
      "settings": {
        "save_to_file": true,
        "dns": ["104.18.2.115", "104.18.3.115"]
      },
      "prompt_opts": {
        "model": "tngtech/deepseek-r1t2-chimera:free",
        "system": "Make your answer concise but complete. No yapping. Direct professional tone. Emoji is ok.",
        "priority": "price",
        "quiet": false,
        "show_reasoning": false,
        "reasoning": {
          "enabled": true,
          "effort": "medium"
        }
      }
    }
  '';
  programs.git = {
    enable = true;
    userName = "Jon Bradley";
    userEmail = "weatchu@gmail.com";

    extraConfig = {
      core.editor = "hx";
      core.pager = "bat --style=plain --pager=never";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  fonts.fontconfig.enable = true;

  # Add stuff for your user as youe see fit:
  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };

  # whats your favor one?
  programs.alacritty = {
    enable = true; # 🚀 Enable Alacritty configuration
    settings = {
      # ⭐ Example themes (pick one):
      # Dracula theme
      # colors = {
      #   primary = {
      #     background = "#282a36";
      #     foreground = "#f8f8f2";
      #   };
      #   normal = {
      #     black   = "#000000";
      #     red     = "#ff5555";
      #     green   = "#50fa7b";
      #     yellow  = "#f1fa8c";
      #     blue    = "#bd93f9";
      #     magenta = "#ff79c6";
      #     cyan    = "#8be9fd";
      #     white   = "#bbbbbb";
      #   };
      # };

      # Gruvbox Dark (alternative)
      colors = {
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };
        normal = {
          black   = "#282828";
          red     = "#cc241d";
          green   = "#98971a";
          yellow  = "#d79921";
          blue    = "#458588";
          magenta = "#b16286";
          cyan    = "#689d6a";
          white   = "#a89984";
        };
      };

      env.TERM = "xterm-256color";
      # Other settings (customize as needed)
      font = {
        size = 15;
        normal.family = "FiraCode Nerd Font";
      };
      window = {
        startup_mode = "Maximized";
        opacity = 0.9;
        decorations = "none";
        dimensions = {
          columns = 80;
          lines = 14;
        };
        resize_increments = true;
      };
      selection.save_to_clipboard = true;
     };
  };

  home.activation.importGPGKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Import GPG private keys from sops into user's GPG keyring
    # the sops secrets are now hardcoded here, if I change them in the sops file
    # I need to update this too.
    if [ -f /run/secrets/gpg_private_keys ]; then
      $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --import --batch /run/secrets/gpg_private_keys
      echo "GPG keys imported to user keyring"
    fi
  '';
   
  ### ======= more SHELL type things ======= ###
  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.yazi.enableBashIntegration = true;
  programs.starship.enableBashIntegration = true;
  programs.readline.enable = true; 
  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export EDITOR=hx
      . /etc/profile.d/aikey.sh
      set -o vi
    '';
    shellAliases = {
      e = "hx";
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      "?" = "${duckduckgo-search}/bin/duckduckgo-search";
      gc = "git commit";
      ga = "git add";
      gs = "git status --short";
      cow = "nix run nixpkgs#cowsay --";
      y = "nix run nixpkgs#yazi --";
      b = ''
          _b() {
            local target="$(hostname)"
            echo "host target is: == $target =="
            if [[ "$(basename $(pwd))" != "ktr-flake" ]]; then
              echo 'in flake directory?'
              fd -t d -1 ktr-flake
              return 0
            else
              echo "inside ktr-flake already..."
              sudo nixos-rebuild switch --flake .#$target
              if [ $? -eq 0 ]; then
                MSG="successful build: $(date)"
                git add .
                git commit -m "$MSG"
                echo "$MSG"
                echo "remember to reload ~/.bashrc"
              else
                echo "Not built right.. :("
              fi
            fi
          }; _b
        '';
      m = ''
        _m() {
          echo " -==>> ktr's MENU -==>>"
          echo "    j - journal <search>  j. to commit"
          echo "   i - injest <file>     b build $(hostname)"
          echo "  p - print <file>"
        }; _m
      '';
    };
    profileExtra = ''
      export EDITOR=hx
    '';
  };
}
