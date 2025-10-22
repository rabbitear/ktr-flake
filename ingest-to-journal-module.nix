{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ingest-to-journal;
  journal-dir = "${config.home.homeDirectory}/.journal";
  
  ingest-to-journal = pkgs.writeShellScript "ingest-to-journal" ''
    #!/usr/bin/env bash
    # ingesting script here :)
    echo "hi there, ingest coming soon"
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
    home.packages = [ pkgs.file ];
    home.shellAliases.i = "${ingest-to-journal}";
  };
}
