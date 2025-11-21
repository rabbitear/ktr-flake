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

  outputs = { self, nixpkgs, home-manager, sops-nix, nix-ai-tools, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # export the ort package built from ./ort.nix
    packages.${system} = {
      ort = pkgs.callPackage ./my-addition/ort.nix {};
      mcpo = pkgs.callPackage ./my-addition/mcpo.nix {};
    };

    # a development shell to work on ort
    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.clang
          pkgs.pkg-config
          pkgs.openssl
          pkgs.zlib
          pkgs.git
        ];
        shellHook = ''
          echo "Entered ort dev shell"
          export CARGO_HOME="$HOME/.cache/ort-cargo"
          export CARGO_TARGET_DIR=target
          export RUST_BACKTRACE=1
          echo "Hints: cargo build; cargo run --bin <name>; cargo test"
        '';
      };

      # keep your existing NixOS configurations intact
      # Python development shell
      crushpython = pkgs.mkShell {
        buildInputs = [
          pkgs.python3
          pkgs.python3Packages.numpy
          pkgs.python3Packages.pandas
          pkgs.python3Packages.jupyter
          pkgs.python3Packages.pip
          pkgs.python3Packages.uv
        ];
        shellHook = ''
          mkdir -p $HOME/.local/share/crushpython/pip
          export PIP_CACHE_DIR=$HOME/.local/share/crushpython/pip
          export PIP_CONFIG_FILE=$HOME/.config/crushpython/pip.conf
          mkdir -p $HOME/.config/crushpython
          echo "[global]" > $HOME/.config/crushpython/pip.conf
          echo "cache-dir = $PIP_CACHE_DIR" >> $HOME/.config/crushpython/pip.conf
          export PYTHONPATH="$PYTHONPATH:$PWD"
          echo "Crush Python development environment ready"
          echo "Use 'python' for Python interpreter"
          echo "Use 'pip install' to install packages (dspy will be installed automatically)"
          pip install dspy-ai --no-input || true
        '';
      };
    };

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
          ./programs+services
          ./tips.nix
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
              users.kreator = import ./users+home;
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
          ./programs+services
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
              users.kreator = import ./users+home;
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
          ./programs+services
          #./programs+services/ollama-cuda.nix
          ./programs+services/openwebui.nix
          ./programs+services/searx.nix
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
              users.kreator = import ./users+home;
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
          ./programs+services
          ./programs+services/ollama-rocm.nix
          ./programs+services/chromecast.nix
          ./programs+services/n8n-sasha.nix
          ./programs+services/searx.nix
          ./programs+services/openwebui.nix
          ./programs+services/graphics-programs.nix
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
              users.kreator = import ./users+home;
              backupFileExtension = "backup";
            };
          }
        ];
      };
      wendy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/wendy/configuration.nix
          ./programs+services
          ./programs+services/searx.nix
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
              users.kreator = import ./users+home;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
  };
}
