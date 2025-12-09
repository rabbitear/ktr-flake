{ config, pkgs, ... }:

{
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
    ## Our mcpo
    (import ../my-addition/mcpo.nix { inherit pkgs; })
  ];
}