{ config, pkgs, ... }:

{
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
  };
  programs.git = {
    enable = true;
    userName = "Jon Bradley";
    userEmail = "weatchu@gmail.com";

    extraConfig = {
      core.editor = "hx";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
  programs.bash = {
    enable = true;
    shellAliases = {
      p = "bat -np";
    };
    profileExtra = ''
      echo echo welcome to kreators bash shell on nix
    '';
  };
}
