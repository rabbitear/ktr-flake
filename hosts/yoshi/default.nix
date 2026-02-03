{ config, pkgs, lib, home-manager, inputs, ... }:
{
  imports = [
    ./configuration.nix
    ../../shared
    ./modules/ollama-cuda.nix
    ./modules/nvidia-cuda.nix
    #../../shared/services/openwebui.nix
    ../../shared/services/searx.nix
    ../../shared/services/flatpak.nix
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.kreator = import ../../users+home;
        backupFileExtension = "backup";
      };
    }
  ];
}
