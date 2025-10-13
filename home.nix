{ config, pkgs, ... }:

{
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
    packages = with pkgs; [
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ];
  }
  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      p = "bat -np";
    }
    profileExtra = ''
      echo "echo welcome to kreators bash shell on nix"
    '';
  };
}
