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
  #################################
  # fshow - git commit browser
  # (enter for show, ctrl-d for diff, ` toggles sort)
  # 
  # fshow = pkgs.writeShellApplication {
  #   name = "fshow";
  #   text = ''
  #     #!/bin/sh
  #     fshow() {
  #       local out shas sha q k
  #       while out=$(
  #           git log --graph --color=always \
  #               --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  #           fzf --ansi --multi --no-sort --reverse --query="$q" \
  #               --print-query --expect=ctrl-d --toggle-sort=\`); do
  #         q=$(head -1 <<< "$out")
  #         k=$(head -2 <<< "$out" | tail -1)
  #         shas=$(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  #         [ -z "$shas" ] && continue
  #         if [ "$k" = ctrl-d ]; then
  #           git diff --color=always $shas | less -R
  #         else
  #           for sha in $shas; do
  #             #git show --color=always $sha | less -R
  #           done
  #         fi
  #       done
  #     }
  #     fshow "$@"
  #   '';
  # };
  ########
  # AND...
  journalApp = pkgs.writeShellApplication {
    name = "journal";
    # runtimeDependencies = [
    #   pkgs.helix
    #   pkgs.mkdir
    #   pkgs.dateutils
    # ];
    text = ''
      #!/bin/sh
      set -euo pipefail

      JOURNAL_DIR="$HOME/journal"
      mkdir -p "$JOURNAL_DIR"

      DATE="$(date +%F)"           # YYYY-MM-DD
      TIME="$(date +%T)"           # HH:MM:SS
      FILE="$JOURNAL_DIR/$DATE.md"

      # If file doesn't exist, create a header with date
      if [ ! -f "$FILE" ]; then
        printf "# Journal — %s\n\n" "$DATE" > "$FILE"
      fi

      # Append a timestamped entry separator and open in helix
      printf "\n## %s\n\n" "$TIME" >> "$FILE"
      exec "${pkgs.helix}/bin/hx" "$FILE"
    '';
  };
in

{
  imports = [
    ./gnome.nix
  ];
  home.packages = [
    journalApp
    #fshow
    duckduckgo-search
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fantasque-sans-mono
  ];
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
  };
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
        #initial-window-size-pixels = "1200x500";
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
    shellAliases = {
      p = "bat --style=header-filename,header-filesize --paging=never";
      e = "hx";
      j = "journal";
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      "?" = "${duckduckgo-search}/bin/duckduckgo-search";
      gc = "git commit";
      ga = "git add";
      gs = "git status --short";
    };
    profileExtra = ''
      echo echo welcome to kreators bash shell on nix
      export EDITOR=hx
    '';
  };
}
