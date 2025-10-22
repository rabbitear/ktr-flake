{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.printer;
  journal-dir = "${config.home.homeDirectory}/.journal";

  printer-script = pkgs.writeShellScript "printer1" ''
    #!/usr/bin/env bash
    if [[ "$#" -gt 0 ]]; then
      for path in "$@"; do
        if [[ ! -e "$path" ]]; then
          printf '%s: file not found\n' "$path"
          continue
        fi
        if [[ ! -r "$path" ]]; then
          printf '%s: not readable\n' "$path"
          continue
        fi
        mime=$(file --brief --mime-type -- "$1")
        case "$mime" in
          image/*)
            echo "🖼️  $path → image ($mime) – opening with imv"
            imv -- "$path" &
            ;;

          text/*)
            bat --style=header-filename,header-filesize --paging=never -- "$path"
            ;;

          *)
            echo "??? $path -> $mime -- something esle"
            ;;
        esac
      done
    else
      JOURNAL_DIR="${journal-dir}"
      YEAR=$(date +%Y)
      DATE=$(date +%m-%d)
      JOURNAL_FILE="$JOURNAL_DIR/$YEAR/$DATE.md"
      if [[ -e "$JOURNAL_FILE" ]]; then
        bat --style=header-filename,header-filesize,numbers,changes --paging=never -- "$JOURNAL_FILE"
      else
        echo "No journal, an opportunity to write :)"
      fi
    fi
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
    home.file.".local/bin/printer1" = {
      source = printer-script;
      executable = true;
    };

    home.packages = [ pkgs.bat pkgs.file pkgs.imv ];
    home.shellAliases.p = "${printer-script}";
  };
}
