
let
  hostname = builtins.getEnv "HOSTNAME";
in
{
  description = "kreator, A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nix-ai-tools, ... }: {
    nixosConfigurations = {
      ${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${hostname}/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (final: prev: {
                nix-ai-tools = nix-ai-tools.packages.${prev.system};
              })
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.kreator = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
  };
}
