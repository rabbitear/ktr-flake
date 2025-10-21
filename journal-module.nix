{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.journal;
  journal-dir = "${config.home.homeDirectory}/.journal";

  journal-script = pkgs.writeShellScript "journal" ''
    #!/usr/bin/env bash

    JOURNAL_DIR="${journal-dir}"
    YEAR=$(date +%Y)
    DATE=$(date +%m-%d)

    # Create journal directory structure if it doesn't exist
    mkdir -p "$JOURNAL_DIR/$YEAR"

    # Create full path for today's journal file
    JOURNAL_FILE="$JOURNAL_DIR/$YEAR/$DATE.md"

    # Format: "Wednesday, October 20, 2025"
    HEADER_DATE=$(date +"%A, %B %d, %Y")

    # Ensure the journal file exists and has a header
    if [[ ! -f "$JOURNAL_FILE" ]]; then
        echo "# $HEADER_DATE" > "$JOURNAL_FILE"
        echo "" >> "$JOURNAL_FILE"
    fi

    # Store the file's state before editing
    if [[ -f "$JOURNAL_FILE" ]]; then
        ORIGINAL_CONTENT=$(cat "$JOURNAL_FILE")
    fi

    # Open today's journal entry in Helix editor, starting at the end of the file
    ${pkgs.helix}/bin/hx "+$" "$JOURNAL_FILE"

    # If journal directory is a git repo, add the file only if it has changed
    if [[ -d "$JOURNAL_DIR/.git" ]] && [[ -f "$JOURNAL_FILE" ]]; then
        CURRENT_CONTENT=$(cat "$JOURNAL_FILE")
        if [[ "$ORIGINAL_CONTENT" != "$CURRENT_CONTENT" ]]; then
            git -C "$JOURNAL_DIR" add "$YEAR/$DATE.md"
        fi
    fi
  '';

in {
  options.programs.journal = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable journal application for taking notes";
    };
  };

  config = mkIf cfg.enable {
    home.file.".local/bin/journal" = {
      source = journal-script;
      executable = true;
    };

    home.file.".journal".source = null;
    home.file.".journal".recursive = true;
    home.file.".journal".isDirectory = true;

    home.packages = [ pkgs.helix pkgs.marksman ];

    # Create an alias 'j' for quick access
    home.shellAliases.j = "${journal-script}";
  };
}
