{ inputs }:
[
  ./configuration.nix
  ../../shared
  ../../shared/searx.nix
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
  {
    nixpkgs = {
      overlays = [
        (final: prev: {
          nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};
        })
      ];
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.kreator = import ../../users+home;
      backupFileExtension = "backup";
    };
  }
]