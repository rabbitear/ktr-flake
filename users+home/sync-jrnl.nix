# jrnl-git-repo
# ^ that is the variable we're looking for that holds the path of the git repo, it exists in sops.
{config, pkgs, ...}:
{
  systemd.user = {
    services.journal-sync = {
      Unit.Description = "Sync journal repository";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.git}/bin/git -C ${config.home.homeDirectory}/.journal pull --ff-only";
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
