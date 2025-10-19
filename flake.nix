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

  outputs = { self, nixpkgs, home-manager, sops-nix, nix-ai-tools, ... }@inputs: {
    nixosConfigurations = {
      ######################
      #                    #
      #   the otter node   #
      #                    #
      ######################
      otternode = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/otternode/configuration.nix
          ./common-station.nix
          # ktr - searx.nix is not ready yet, searx.env needs attention.
          #./searx.nix
          ./tips.nix
          ./n8n.nix
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
      #######################################
      # 
      #  --+->
      #   hacknet  --+->
      #     ------------+->
      # 
      # 
      hacknet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/hacknet/configuration.nix
          ./common-station.nix
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
      #########
      #       #
      #       #
      # ===== #
      # yoshi #
      # ===== #
      #       #
      #       #
      #       #
      #########
      yoshi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/yoshi/configuration.nix
          ./common-station.nix
          ./ollama-cuda.nix
          ./openwebui.nix
          ./searx.nix
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
      #####################################
      #                                   # 
      #        <-=+=- Sasha -=+=->        #
      #                                   # 
      #####################################
      sasha = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/sasha/configuration.nix
          ./common-station.nix
          ./ollama-rocm.nix
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
