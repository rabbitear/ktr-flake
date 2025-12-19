# graphics-programs.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs.blender-hip
    pkgs.openscad
    pkgs.openscad-lsp
    pkgs.gimp3
    #blender-mcp
  ];
}
