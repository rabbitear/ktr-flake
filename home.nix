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
    ./home-gnome.nix
  ];
  home.packages = [
    journalApp
    #fshow
    duckduckgo-search
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

  programs.bash = {
    enable = true;
    shellAliases = {
      p = "bat --style=header-filename,header-filesize --paging=never";
      e = "hx";
      j = "journal";
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      "?" = "${duckduckgo-search}/bin/duckduckgo-search";
      gc = "git commit";
      ga = "git add";
      gs = "git status --short";
      #gl = "fshow";
    };
    profileExtra = ''
      echo echo welcome to kreators bash shell on nix
      export EDITOR=hx
    '';
  };
}
