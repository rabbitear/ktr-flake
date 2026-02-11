{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openscad
    openscad-lsp
    gimp3
  ];
}
