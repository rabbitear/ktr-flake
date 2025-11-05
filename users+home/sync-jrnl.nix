

systemd.user = {
  services.journal-sync = {
    Unit.Description = "Sync journal repository";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.git}/bin/git -C /path/to/your/journal/repo pull --ff-only";
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

