{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.journal;
  journal-dir = "${config.home.homeDirectory}/.journal";

  # === Embedded Helix configuration === 
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

    if [[ ! -d "$JOURNAL_DIR" ]]; then
      echo "No journal in home, create with j."
      exit 1
    fi

    # Create journal directory structure if it doesn't exist
    mkdir -p "$JOURNAL_DIR/$YEAR"

    # Args?
    if [[ "$#" -gt 0 ]]; then
      # === Text Search journal ===
      pushd "$JOURNAL_DIR" >/dev/null
      rg --color=never --line-number --no-heading "$*" | \
        fzf --delimiter : \
        --nth 1,2,3 \
        --bind "enter:become:${pkgs.helix}/bin/hx --working-dir $JOURNAL_DIR --config ${journal-config} {1}:{2}"
      popd
    else
      # === Make journal entery ===
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

      # Open today's journal entry in Helix editor with journal-specific config
      ${pkgs.helix}/bin/hx --working-dir $JOURNAL_DIR --config "${journal-config}" "$JOURNAL_FILE:9999"

      # ktr - in the future, this should git add any file that has been changed,
      #       not just a journal file.  If we search, we could be editing a file
      #       that is not a journal file. 
      # If journal directory is a git repo, add the file only if it has changed
      if [[ -d "$JOURNAL_DIR/.git" ]] && [[ -f "$JOURNAL_FILE" ]]; then
          CURRENT_CONTENT=$(cat "$JOURNAL_FILE")
          if [[ "$ORIGINAL_CONTENT" != "$CURRENT_CONTENT" ]]; then
              git -C "$JOURNAL_DIR" add "$YEAR/$DATE.md"
              git -C "$JOURNAL_DIR" diff --cached
              echo "j. - commit & push to origin"
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
    remoterepository = mkOption {
      type = types.str;
      default = "";
      description = "Remote git repository for journal";
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
        GITREMOTE="${cfg.remoterepository}"
        JOURNAL_DIR="${journal-dir}"
        echo "== Journal Update =="
        echo "Remote git repository: $GITREMOTE"

        if [[ ! -d "$JOURNAL_DIR" ]]; then
          # no journal dir exists, close it.
          [[ -z "$GITREMOTE" ]] && echo "remoterepository not set" && return 1
          git clone "$GITREMOTE" "$JOURNAL_DIR"
          if (( $? == 0 )); then
            echo "created $JOURNAL_DIR"
            return 1
          fi
        fi

        # We have a direcotry here.

        # Q: do we need to pull
        # Q: add? commit? push?

        if [[ -n $(git -C "$JOURNAL_DIR" status --porcelain) ]]; then
          echo "Changes detected - committing..."
          
          # Add all changes (including new files)
          git -C "${journal-dir}" add -A || { echo "Error: Failed to stage changes"; return 1; }
          
          # Commit with automatic message (modify this if you need specific messages)
          git -C "${journal-dir}" commit -m "Auto-commit: $(date +"%Y-%m-%d %H:%M:%S")" || { echo "Error: Failed to commit"; return 1; }

          # Pull before push...
          git -C "${journal-dir}" pull || { echo "Error: Failed to pull changes"; return 1; }

          # Push the new commit
          git -C "${journal-dir}" push || { echo "Error: Failed to push changes"; return 1; }

          echo "Successfully committed and pushed changes"
        else
          echo " - No changes to commit -"
          git -C "${journal-dir}"" pull || { echo "Error: Failed to PULL"; return 1; }
        fi
      }; _jupdate
    '';
  };
}
