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

          application/pdf)
            echo "📄 $path is a PDF – opening with zathura"
            zathura "$path" &
            ;;

          # ===============================================
          # START -- mpv mime types handler -> gpt-oss-120b 
          # ===============================================
          # -----------------------------------------------------------------
          #  MPV – the universal media player
          #
          #  mpv can decode *any* audio/video MIME type that the underlying
          #  FFmpeg libraries understand.  The list below is the exhaustive
          #  set of MIME types reported by `ffprobe -show_entries format=format_name`
          #  (which is exactly what mpv uses internally).  We group them
          #  into three convenient glob patterns:
          #
          #      • video/*                – all video types
          #      • audio/*                – all audio types
          #      • application/*          – container‑only types that have no
          #                                 top‑level video/audio MIME (e.g.
          #                                 Matroska, Ogg, WebM, etc.)
          #
          #  This single case entry therefore matches **every** file mpv
          #  can play, without having to enumerate each individual subtype.
          # -----------------------------------------------------------------
          video/*|audio/*|application/ogg|application/vnd.apple.mpegurl|\
          application/x-mpegURL|application/x-matroska|application/x-webm|\
          application/x-flac|application/x-ogg|application/x-aac|\
          application/x-wav|application/x-mp4|application/x-mpegurl|\
          application/x-msvideo|application/x-quicktimeplayer|\
          application/x-m4v|application/x-m4a|application/x-3gpp|\
          application/x-3gpp2|application/x-hls|application/x-dash+xml|\
          application/octet-stream)
            # ---------------------------------------------------------
            #  All of the above are known to be playable by mpv.
            #  Feel free to add any extra mpv options here, e.g.
            #      mpv --fs --no-border "$file_to_open"
            # ---------------------------------------------------------
              
            echo "📄 $path is a $mime – opening with mpv"
            mpv "$file_to_open"
            ;;
          # ===============================================
          # STOP ---
          # ===============================================

          # -----------------------------------------------------------------
          # Text‑like files – everything bat can colourise nicely
          # -----------------------------------------------------------------
          text/*|\
          application/json|application/xml|application/javascript|\
          application/x-yaml|application/x-toml|application/xhtml+xml|\
          application/rtf|application/atom+xml|application/rss+xml|\
          application/vnd.ms-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|\
          application/vnd.ms-powerpoint|application/vnd.openxmlformats-officedocument.presentationml.presentation|\
          application/vnd.ms-word|application/vnd.openxmlformats-officedocument.wordprocessingml.document|\
          application/x-markdown|text/markdown|text/x-markdown|\
          application/x-php|application/x-perl|application/x-python|application/x-ruby|\
          application/x-shellscript|application/x-csh|application/x-bash|\
          application/x-asm|application/x-java|application/x-c|application/x-cpp|\
          application/x-go|application/x-rust)
              echo "📃 $path → $mime – displaying with bat"
              # `bat` options you may like:
              #   --style=header,grid   – show a header and a grid
              #   --paging=always       – like `less`
              #   --color=always        – force colour even when piped
              bat --style=header,grid --paging=always --color=always -- "$path"
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

    home.packages = [ pkgs.bat pkgs.file pkgs.imv pkgs.zathura ];
    home.shellAliases.p = "${printer-script}";
  };
}
