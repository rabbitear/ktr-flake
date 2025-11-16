{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.blender-hip
  ];
}
