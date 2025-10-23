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
    YEAR=$(date +%Y)
    DATE=$(date +%m-%d)
    mkdir -p "$KB_ROOT/$YEAR"
    JOURNAL_FILE="$KB_ROOT/$YEAR/$DATE.md"
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
<<<<<<< HEAD
        mime_type=$(file --brief --mime-type -- "$src" | cut -d'/' -f1)
=======
        mime=$(file -b --mime-type "$src")
        echo mime is $mime
        type=$${mime%%/*}          # e.g. text, image, application
        subtype=$${mime#*/}        # e.g. plain, png, json
>>>>>>> c2c709e (successful build: Wed Oct 22 04:19:31 PM AKDT 2025)
    
        # -----------------------------------------------------------------
        # 3. Build destination directory (type/subtype hierarchy)
        # -----------------------------------------------------------------
<<<<<<< HEAD
        target_dir="$KB_ROOT/$mime_type"
=======
        if [[ $subtype == "$type" || -z "$subtype" ]]; then
            target_dir="$KB_ROOT/$type"
        else
            target_dir="$KB_ROOT/$type/$subtype"
        fi
>>>>>>> c2c709e (successful build: Wed Oct 22 04:19:31 PM AKDT 2025)
        mkdir -p "$target_dir"
        echo target_dir $target_dir
    
        # -----------------------------------------------------------------
        # 4. Build a safe, unique destination file name
        # -----------------------------------------------------------------
<<<<<<< HEAD
        orig_base=$(basename "$src")          # original file name
        nospace_base=$(echo "$orig_base" | sed 's/ /_/g')
        new_base=$(date +%s)_$nospace_base
        dest="$target_dir/$new_base"

        # -----------------------------------------------------------------
        # 5. Copy the file (preserve metadata)
        # -----------------------------------------------------------------
        cp -a "$src" "$dest"
        echo "" >> $JOURNAL_FILE
        echo "[$orig_base](../$mime_type/$new_base)" >> $JOURNAL_FILE
=======
        # epoch="$(date +%s)"                     # Unix epoch seconds
        # orig_base=$(basename "$src")          # original file name
        # safe_base=$(sanitize_name "$orig_base")   # <-- NEW STEP
        # ebase=$epoch/$safe_base
        # dest=$target_dir/$ebase
        # echo "dest is NOW: $dest"
        # If, for any reason, the name already exists (extremely unlikely),
        # append a counter before the original name.
        # if [[ -e "$dest" ]]; then
            # i=1
            # while [[ -e $${target_dir}/$${epoch}_$${i}_$${safe_base} ]]; do ((i++)); done
            # dest=$${target_dir}/$${epoch}_$${i}_$${safe_base}
        # fi
    
        # -----------------------------------------------------------------
        # 5. Copy the file (preserve metadata)
        # -----------------------------------------------------------------
        #echo 'cp -a "$src" "$dest"'
        #echo "Added: "$dest"
        echo WHATUP
>>>>>>> c2c709e (successful build: Wed Oct 22 04:19:31 PM AKDT 2025)
    
        # -----------------------------------------------------------------
        # 6. Stage the new file in the repo (optional but convenient)
        # -----------------------------------------------------------------
<<<<<<< HEAD
        if [[ -d $KB_ROOT/.git ]]; then
          git -C "$KB_ROOT" add "$dest"
          echo " --> but do we really want to commit here?"
          git -C "$KB_ROOT" commit -m "Ingested: $dest"
        fi
=======
        #if [[ -d $KB_ROOT/.git ]]; then
        #  (cd "$KB_ROOT" && git add "$dest" && git commit -m "Ingested: $dest")
        #fi
>>>>>>> c2c709e (successful build: Wed Oct 22 04:19:31 PM AKDT 2025)
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
