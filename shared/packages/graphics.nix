{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blender-hip
    openscad
    openscad-lsp
    gimp3
  ];
}
