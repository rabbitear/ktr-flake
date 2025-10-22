{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.printer;
  journal-dir = "${config.home.homeDirectory}/.journal";

  printer-script = pkgs.writeShellScript "printer1" ''
    #!/usr/bin/env bash
    if [[ "$#" -gt 0 ]]; then
      echo -e "\e[0;32mprint \e[33m$*\e[0m"
      bat --style=header-filename,header-filesize --paging=never "$*"
    else
      JOURNAL_DIR="${journal-dir}"
      YEAR=$(date +%Y)
      DATE=$(date +%m-%d)
      JOURNAL_FILE="$JOURNAL_DIR/$YEAR/$DATE.md"
      if [[ -e "$JOURNAL_FILE" ]]; then
        bat --style=header-filename,header-filesize,numbers,changes --paging=never "$JOURNAL_FILE"
      else
        echo "No journal, a change to write :)"
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

    home.packages = [ pkgs.bat ];
    home.shellAliases.p = "${printer-script}";
  };
}
