{ pkgs, config, ... }:
{
  nixpkgs.config.packageOverides = pkgs: {
    bun = pkgs.bun.override { target = "baseline"; };
  };
  programs.bun = {
    enable = true;
    settings = {
      smol = true;
      telemetry = false;
      test = {
        coverage = true;
        coverageThreshold = 0.9;
      };
      install.lockfile = {
        print = "yarn";
      };
    };
  };
}
