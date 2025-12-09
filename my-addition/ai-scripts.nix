{ pkgs }:

let
  # AI Chat interface using ollama
  ai-chat = pkgs.writeShellApplication {
    name = "ai-chat";
    text = ''
      #!/bin/sh
      exec ollama run qwen3:1.7b "$@"
    '';
  };

  # OpenCode interface
  ai-opencode = pkgs.writeShellApplication {
    name = "ai-opencode";
    text = ''
      #!/bin/sh
      exec opencode --model opencode/sonic run "$@"
    '';
  };

  # Journal entry helper
  journal-entry = pkgs.writeShellApplication {
    name = "journal-entry";
    text = ''
      #!/bin/sh
      exec journal entry "$@"
    '';
  };

  # Journal push helper
  journal-push = pkgs.writeShellApplication {
    name = "journal-push";
    text = ''
      #!/bin/sh
      exec journal push "$@"
    '';
  };

  # Journal search helper
  journal-search = pkgs.writeShellApplication {
    name = "journal-search";
    text = ''
      #!/bin/sh
      exec journal search "$@"
    '';
  };

  # Process monitor (CPU)
  process-monitor = pkgs.writeShellApplication {
    name = "process-monitor";
    text = ''
      #!/bin/sh
      exec ps k-%cpu -eo pid,ppid,cmd,%mem,%cpu -w 67 | head -16
    '';
  };

  # Process monitor (all)
  process-monitor-all = pkgs.writeShellApplication {
    name = "process-monitor-all";
    text = ''
      #!/bin/sh
      exec ps -eo pid,ppid,cmd,%mem,%cpu -w 54
    '';
  };

  # Dot diff utility
  dotdiff = pkgs.writeShellApplication {
    name = "dotdiff";
    text = ''
      #!/bin/sh
      # Add your dotdiff implementation here
      echo "dotdiff - placeholder implementation"
    '';
  };

  # Git push helper
  git-sync = pkgs.writeShellApplication {
    name = "git-sync";
    text = ''
      #!/bin/sh
      pass git pull && pass git push && wiki git pull && wiki git push
    '';
  };

in {
  inherit
    ai-chat
    ai-opencode
    journal-entry
    journal-push
    journal-search
    process-monitor
    process-monitor-all
    dotdiff
    git-sync;
}