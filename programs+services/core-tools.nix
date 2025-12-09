{ config, pkgs, ... }:

{
  imports = [
    ../my-addition/mcpo.nix
  ];

  # Core development tools and custom packages
  users.users.kreator.packages = with pkgs; [
    go
    gopls
    golangci-lint-langserver
    delve
  ];

  environment.systemPackages = with pkgs; [
    ## Our ort
    (import ../my-addition/ort.nix { inherit pkgs; })
  ];
}