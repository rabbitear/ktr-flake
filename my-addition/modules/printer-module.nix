{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.printer;
  #journal-dir = "${config.home.homeDirectory}/.journal";

  printer-script = pkgs.writeShellScript "printer1" ''
    p() {
      if [[ ! -t 0 ]]; then
        local bytes
        bat --style=numbers --pager=never /dev/stdin
        return
      fi
    
      local journal_days_ago=
      OPTIND=1
    
      while getopts "j:" opt; do
        case $opt in
          j)
            journal_days_ago=$OPTARG
            ;;
          \?)
            echo "Invalid option: -$OPTARG" >&2
            return 1
            ;;
          :)
            echo "Option -$OPTARG requires an argument." >&2
            return 1
            ;;
        esac
      done
      shift $((OPTIND-1))
    
      local journal_file
      journal_file="$HOME/.journal/$(date +%Y)/$(date +%m-%d).md"
      
      if [[ -n "$journal_days_ago" ]]; then
        journal_file="$HOME/.journal/$(date -d "$journal_days_ago days ago" +%Y)/$(date -d "$journal_days_ago days ago" +%m-%d).md"
        
        if [[ -f "$journal_file" ]]; then
          local bytes
          bytes=$(wc -c < "$journal_file")
          bat --style=numbers --pager=never "$journal_file"
          echo "EOF ($bytes bytes) $journal_file"
        else
          echo "Journal entry not found: $journal_file"
        fi
        return
      fi
      
      if [[ $# -gt 0 ]]; then
        for file_path in "$@"; do
          if [[ -f "$file_path" ]]; then
            if file -L "$file_path" | grep -q "text"; then
              local bytes
              bytes=$(wc -c < "$file_path")
              bat --style=numbers --pager=never "$file_path"
              echo "EOF ($bytes bytes) $file_path"
            else
              echo "📄 $(file -L "$file_path")"
              echo "Use 'xxd \"$file_path\"' to view hex dump"
            fi
          else
            echo "File not found: $file_path"
          fi
        done
        return
      fi
      
      local selected
      selected=$({
        printf "%s\n" "$journal_file (Today's journal 📝)"
        find . -maxdepth 1 -type f 2>/dev/null | sort -r | head -n 15
      } | fzf --height=7 \
               --layout=reverse \
               --prompt='🖨️  ' \
               --no-info \
               --color=bg+:235,bg:236,fg:244,hl:141,fg+:253,hl+:228 \
               --border=none \
               --cycle)
      
      local file_path
      file_path=$(echo "$selected" | head -n 1)
      
      if [[ -z "$file_path" ]]; then
        file_path="$journal_file"
      fi
      
      if [[ "$file_path" == *" ("* ]]; then
        file_path="''${file_path%% (*}"
      fi
      
      if [[ -f "$file_path" ]]; then
        if file -L "$file_path" | grep -q "text"; then
          local bytes
          bytes=$(wc -c < "$file_path")
          bat --style=numbers --pager=never "$file_path"
          echo "EOF ($bytes bytes) $file_path"
        else
          echo "📄 $(file -L "$file_path")"
          echo "Use 'xxd \"$file_path\"' to view hex dump"
        fi
      else
        echo "File not found: $file_path"
      fi
    }
  '';

in {
  options.programs.printer = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable printer application for viewing files";
    };
  };

  config = mkIf cfg.enable {
    home.file.".local/bin/printer2" = {
      source = printer-script;
      executable = true;
    };

    home.packages = [ pkgs.bat pkgs.file pkgs.xxd ];

    programs.bash.initExtra = "source ${printer-script}";
    #programs.zsh.initExtra = "source ${printer-script}";
  };
}
