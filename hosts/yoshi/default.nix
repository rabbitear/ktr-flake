{ inputs }:
[
  ./configuration.nix
  ../../shared
  ./modules/ollama-cuda.nix
  #../../shared/openwebui.nix
  ../../shared/searx.nix
  ../../shared/flatpak.nix
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
  {
    nixpkgs.overlays = [
      (final: prev: {
        nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};
      })
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.kreator = import ../../users+home;
      backupFileExtension = "backup";
    };
  }
]