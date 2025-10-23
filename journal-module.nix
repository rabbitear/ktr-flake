{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.journal;
  journal-dir = "${config.home.homeDirectory}/.journal";

  # Embed the Helix configuration directly in the module
  journal-config = pkgs.writeText "hx-journal.toml" ''
# Helix configuration for journaling

theme = "bogster_light"
#theme = "bogster"
#theme = "ayu_light"

[editor]
# Disable auto-pairing for a more natural writing experience
auto-pairs = false
line-number = "absolute"
cursorline = true
mouse = true
#default-yank-register = "+"
text-width = 72
# save all the time
atomic-save = true
popup-border = "all"

# Set a comfortable line width for prose
rulers = [72]

# Enable smooth scrolling
scrolloff = 5

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.file-picker]
# Show hidden files in file picker
hidden = true

[editor.soft-wrap]
enable = true
# wrap at end of viewport 
wrap-at-text-width = false

[editor.lsp]
enable = true
display-messages = true
auto-signature-help = false
display-inlay-hints = false
display-color-swatches = true
display-signature-help-docs = false
goto-reference-include-declaration = true

[keys.normal.space]
  w = ":w"
  q = ":q"
  r = ":reflow"
  esc = [ "collapse_selection", "keep_primary_selection" ]

  '';

  journal-script = pkgs.writeShellScript "journal" ''
    #!/usr/bin/env bash

    JOURNAL_DIR="${journal-dir}"
    YEAR=$(date +%Y)
    DATE=$(date +%m-%d)

    # Create journal directory structure if it doesn't exist
    mkdir -p "$JOURNAL_DIR/$YEAR"

    # Text Search journal
    # If we have an arg use those for search string
    # ktr- for now the --bind runs our editor, but it doesn't
    #      have to.  It could package up a ENV VAR of the file
    #      and the line number FILE:LINE and move on.  Then we
    #      have either a file we can edit from search or we have
    #      a todays journal file to edit.
    if [[ "$#" -gt 0 ]]; then
      pushd "$JOURNAL_DIR" >/dev/null
      rg --color=never --line-number --no-heading "$*" | \
        fzf --delimiter : \
        --nth 1,2,3 \
        --bind "enter:become:${pkgs.helix}/bin/hx --working-dir $JOURNAL_DIR --config ${journal-config} {1}:{2}"
      popd
    else
      # No args
      # Create full path for today's journal file
      JOURNAL_FILE="$JOURNAL_DIR/$YEAR/$DATE.md"

      # Format: "Wednesday, October 20, 2025"
      HEADER_DATE=$(date +"%A, %B %d, %Y")

      # Ensure the journal file exists and has a header
      if [[ ! -f "$JOURNAL_FILE" ]]; then
          echo "# $HEADER_DATE" > "$JOURNAL_FILE"
          echo "" >> "$JOURNAL_FILE"
      fi
      # ktr -- here we could already have either one of the
      #        files, from search or for todays journal. TBD
      # Store the file's state before editing
      if [[ -f "$JOURNAL_FILE" ]]; then
          ORIGINAL_CONTENT=$(cat "$JOURNAL_FILE")
      fi

      # Open today's journal entry in Helix editor with journal-specific config
      ${pkgs.helix}/bin/hx --working-dir $JOURNAL_DIR --config "${journal-config}" "$JOURNAL_FILE:9999"

      # If journal directory is a git repo, add the file only if it has changed
      if [[ -d "$JOURNAL_DIR/.git" ]] && [[ -f "$JOURNAL_FILE" ]]; then
          CURRENT_CONTENT=$(cat "$JOURNAL_FILE")
          if [[ "$ORIGINAL_CONTENT" != "$CURRENT_CONTENT" ]]; then
              git -C "$JOURNAL_DIR" add "$YEAR/$DATE.md"
              git -C "$JOURNAL_DIR" diff --cached
          fi
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

    home.packages = [ pkgs.helix pkgs.marksman pkgs.fzf pkgs.bat pkgs.ripgrep ];
    home.shellAliases.j = "${journal-script}";
    home.shellAliases."j." = ''
      _jupdate() {
        echo "checking on ${journal-dir} files"
        git -C "${journal-dir}" pull || { echo "Error: Failed to pull changes"; return 1; }
        if [[ -n $(git status --porcelain) ]]; then
            echo "Changes detected - committing..."
            
            # Add all changes (including new files)
            git -C "${journal-dir}" add -A || { echo "Error: Failed to stage changes"; return 1; }
            
            # Commit with automatic message (modify this if you need specific messages)
            git -C "${journal-dir}" commit -m "Auto-commit: $(date +"%Y-%m-%d %H:%M:%S")" || { echo "Error: Failed to commit"; return 1; }
            
            # Push the new commit
            git -C "${journal-dir}" push || { echo "Error: Failed to push changes"; return 1; }
            echo "Successfully committed and pushed changes"
        else
            echo "No changes to commit"
        fi
      }; _jupdate
    '';
  };
}
