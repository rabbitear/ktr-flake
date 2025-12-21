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
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nix-ai-tools, NixVirt, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # export the ort package built from ./ort.nix
    packages.${system} = {
      ort = pkgs.callPackage ./my-addition/packages/ort.nix {};
      #blender-mcp = pkgs.callPackage ./my-addition/packages/blender-mcp.nix {};
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
         modules = import ./hosts/otternode/default.nix { inherit inputs; };
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
         modules = import ./hosts/hacknet/default.nix { inherit inputs; };
       };
       ## Jenny
        jenny = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs.overlays = [
                (final: prev: {
                  bun = prev.bun.overrideAttrs (oldAttrs: {
                    src = prev.fetchurl {
                      url = "https://github.com/oven-sh/bun/releases/download/bun-v${oldAttrs.version}/bun-linux-x64-baseline.zip";
                      hash = "sha256-PVEp4ZdCo0j+8RI1e+cL7O5ZbE0yvE37dWzuYTTi6SU=";
                    };
                  });
                })
              ];
            }
            (import ./hosts/jenny/default.nix { inherit inputs; })
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
        specialArgs = {
          inherit inputs;
          hostName = "yoshi";
        };
         modules = import ./hosts/yoshi/default.nix { inherit inputs; };
      };
       #####################################
       #                                   #
       #        <-=+=- Sasha -=+=->        #
       #                                   #
       #####################################
       sasha = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };
         modules = import ./hosts/sasha/default.nix { inherit inputs; };
       };
       wendy = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };
         modules = import ./hosts/wendy/default.nix { inherit inputs; };
      };
    };
  };
}
