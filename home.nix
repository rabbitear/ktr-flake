{ config, pkgs, ... }:
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
    ./journal-module.nix
    ./printer-module.nix
    ./ingest-module.nix
    ./gnome.nix
  ];

  # My shell scripts.
  programs.journal.enable = true;
  programs.journal.remoterepository = "";
  programs.printer.enable = true;
  programs.ingest-to-journal.enable = true;

  home.packages = [
    duckduckgo-search
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fantasque-sans-mono
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
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  # Add stuff for your user as youe see fit:
  programs.helix = {
    enable = true;
    settings = {
      theme = "ayu_evolve";
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

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Monospace:size=18";
        pad = "4x4";
        dpi-aware = "yes";
        initial-window-size-chars = "80x11";
        initial-window-mode = "windowed";
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
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        #draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export EDITOR=hx
      . /etc/profile.d/aikey.sh
      eval "$(ssh-agent)"
    '';
    shellAliases = {
      e = "hx";
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      "?" = "${duckduckgo-search}/bin/duckduckgo-search";
      gc = "git commit";
      ga = "git add";
      gs = "git status --short";
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
      echo WeLcoMe To: => $(hostname) <=
      export EDITOR=hx
    '';
  };
}
