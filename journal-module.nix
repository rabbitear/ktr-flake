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
default-yank-register = "+"
text-width = 72
# save all the time
atomic-save = true
popup-border = "all"

# Set a comfortable line width for prose
rulers = [80]

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

# Markdown-specific settings
# Associate .md files with marksman language server
#[[language]]
#type = "markdown"
#language-server = "marksman"
  '';

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

    # Open today's journal entry in Helix editor with journal-specific config
    ${pkgs.helix}/bin/hx -c "${journal-config}" "$JOURNAL_FILE:9999"

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

    home.packages = [ pkgs.helix pkgs.marksman ];

    # Create an alias 'j' for quick access
    home.shellAliases.j = "${journal-script}";
  };
}
