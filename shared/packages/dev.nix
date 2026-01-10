{ pkgs, ... }:

{
  users.users.kreator.packages = with pkgs; [
    go
    gopls
    golangci-lint-langserver
    delve
    httpie
    httpie-desktop
  ];

  environment.systemPackages = with pkgs; [
    (import ../../my-addition/packages/ort.nix { inherit pkgs; })
  ];
}
