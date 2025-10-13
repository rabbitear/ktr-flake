{ config, pkgs, ... }:

{
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
  };
  programs.git.enable = true;
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
