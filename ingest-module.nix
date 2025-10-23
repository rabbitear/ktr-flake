{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ingest-to-journal;
  journal-dir = "${config.home.homeDirectory}/.journal";
  
  ingest-to-journal = pkgs.writeShellScript "ingest-to-journal" ''
    #!/usr/bin/env bash
    # ---------------------------------------------------------------
    # ingest.sh – copy a file into a git‑backed knowledge base
    #
    #   ./ingest.sh  /path/to/some‑file.ext  [more files …]
    #
    #   • Detects MIME type with `file --mime-type`
    #   • Creates $KB_ROOT/<type>/<subtype>/ hierarchy
    #   • Prefixes the file name with the current Unix epoch
    #   • **Sanitises the original name** – spaces & any non‑alnum
    #     characters become '_' so the repo never gets “weird” names
    #   • Stages the new file with `git add`
    # ---------------------------------------------------------------
    
    set -euo pipefail      # safer Bash
    
    # -----------------------------------------------------------------
    # Configuration – change to suit your environment
    # -----------------------------------------------------------------
    # Root of the knowledge‑base repository
    KB_ROOT="${journal-dir}"
    
    # -----------------------------------------------------------------
    # Helper functions
    # -----------------------------------------------------------------
    usage() {
        cat <<EOF
    Usage: $(basename "$0") FILE [FILE …]
    
    Copy each FILE into the knowledge‑base, sorting by its MIME type,
    prefixing the name with the current Unix epoch and sanitising
    any whitespace or “odd” characters (they become underscores).
    
    Repository root: $KB_ROOT
    EOF
        exit 1
    }
    
    # -----------------------------------------------------------------
    # Sanitize a file name
    #   - replace any run of characters other than [A‑Za‑z0‑9._-] with _
    #   - also collapse multiple consecutive underscores into a single _
    #   - strip leading / trailing underscores (optional, tidy)
    # -----------------------------------------------------------------
    # sanitize_name() {
    #     local name="$1"
    #     # 1) replace disallowed chars with _
    #     name=$${name//[^[:alnum:]._-]/_}
    #     # 2) collapse repeated underscores
    #     name=$(echo "$name" | tr -s '_' )
    #     # 3) trim leading / trailing underscores (optional)
    #     name=$${name##_}
    #     name=$${name%_}
    #     printf '%s' "$name"
    # }

    sanitize_name() {
        printf '%s' "$1" | \
        sed 's/[^[:alnum:]._-]/_/g' | \  # Replace illegal chars with underscore
        tr -s '_' | \                    # Collapse consecutive underscores
        sed -e 's/^_*//' -e 's/_*$//'    # Trim leading/trailing underscores
    }

    
    # -----------------------------------------------------------------
    # Main – process each argument
    # -----------------------------------------------------------------
    if (( $# == 0 )); then
        usage
    fi
    
    for src in "$@"; do
        # -----------------------------------------------------------------
        # 1. Basic sanity checks
        # -----------------------------------------------------------------
        if [[ ! -e $src ]]; then
            echo "Error: $src does not exist" >&2
            continue
        fi
        if [[ ! -r $src ]]; then
            echo "Error: $src is not readable" >&2
            continue
        fi
    
        # -----------------------------------------------------------------
        # 2. Determine MIME type
        # -----------------------------------------------------------------
        mime_type=$(file --brief --mime-type -- "$src" | cut -d'/' -f1)
    
        # -----------------------------------------------------------------
        # 3. Build destination directory (type/subtype hierarchy)
        # -----------------------------------------------------------------
        target_dir="$KB_ROOT/$mime_type"
        mkdir -p "$target_dir"
    
        # -----------------------------------------------------------------
        # 4. Build a safe, unique destination file name
        # -----------------------------------------------------------------
        orig_base=$(basename "$src")          # original file name
        safe_base=$(sanitize_name "$orig_base")   # <-- NEW STEP
        dest="$target_dir/$(date +%s)_$safe_base"
    
        # If, for any reason, the name already exists (extremely unlikely),
        # append a counter before the original name.
        if [[ -e $dest ]]; then
            i=1
            while [[ -e "$target_dir/$epoch_$i_$safe_base" ]]; do ((i++)); done
            dest="$target_dir/$epoch_$i_$safe_base"
        fi
    
        # -----------------------------------------------------------------
        # 5. Copy the file (preserve metadata)
        # -----------------------------------------------------------------
        cp -a "$src" "$dest"
        echo "Added: $dest"
    
        # -----------------------------------------------------------------
        # 6. Stage the new file in the repo (optional but convenient)
        # -----------------------------------------------------------------
        if [[ -d $KB_ROOT/.git ]]; then
          (cd "$KB_ROOT" && git add "$dest" && git commit -m "Ingested: $dest")
        fi
    done
  '';
in {
  options.programs.ingest-to-journal = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable ingesting files in to journal";
    };
  };
  config = mkIf cfg.enable {
    home.file.".local/bin/ingest-to-journal" = {
      source = ingest-to-journal;
      executable = true;
    };
    home.packages = [ pkgs.file pkgs.gnused pkgs.coreutils ];
    home.shellAliases.i = "${ingest-to-journal}";
  };
}
