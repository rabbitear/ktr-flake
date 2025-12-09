{ pkgs }:

let
  ai-chat = pkgs.writeShellApplication {
    name = "ai-chat";
    text = ''
      exec ollama run qwen3:1.7b "$@"
    '';
  };

  ai-opencode = pkgs.writeShellApplication {
    name = "ai-opencode";
    text = ''
      exec opencode run "$@"
    '';
  };

  journal-entry = pkgs.writeShellApplication {
    name = "journal-entry";
    text = ''
      exec journal entry "$@"
    '';
  };

  journal-push = pkgs.writeShellApplication {
    name = "journal-push";
    text = ''
      exec journal push "$@"
    '';
  };

  journal-search = pkgs.writeShellApplication {
    name = "journal-search";
    text = ''
      exec journal search "$@"
    '';
  };

  process-monitor = pkgs.writeShellApplication {
    name = "process-monitor";
    text = ''
      exec ps k-%cpu -eo pid,ppid,cmd,%mem,%cpu -w 67 | head -16
    '';
  };

  process-monitor-all = pkgs.writeShellApplication {
    name = "process-monitor-all";
    text = ''
      exec ps -eo pid,ppid,cmd,%mem,%cpu -w 54
    '';
  };

  dotdiff = pkgs.writeShellApplication {
    name = "dotdiff";
    text = ''
      echo "dotdiff - placeholder"
    '';
  };

  git-sync = pkgs.writeShellApplication {
    name = "git-sync";
    text = ''
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