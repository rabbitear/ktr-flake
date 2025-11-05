# jrnl-git-repo
# ^ that is the variable we're looking for that holds the path of the git repo, it exists in sops.
{config, pkgs, ...}:
{
  systemd.user = {
    services.journal-sync = {
      Unit.Description = "Sync journal repository";
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "sync-journal" ''
          pushd ${config.home.homeDirectory}/.journal
        
          # Auto-commit local changes if they exist
          if ! git diff-index --quiet HEAD --; then
            git add -A
            git commit -m "Auto-commit journal changes by systemd"
          fi
        
          # Safe pull (will still fail if upstream requires merge resolution)
          git pull --ff-only
          popd
        '';
        TimeoutStopSec = 30;
      };
    };
  
    timers.journal-sync = {
      Unit.Description = "Timer for journal repo syncing";
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "30m";
        AccuracySec = "5m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
