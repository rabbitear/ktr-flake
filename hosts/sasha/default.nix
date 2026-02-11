{ inputs }:
[
  ./configuration.nix
  ../../shared
  ./modules/ollama-vulkan.nix
  ../../shared/services/avahi.nix
  ../../shared/services/searx.nix
  ../../shared/services/openwebui.nix # was on 6.x 7.2 broke :(  fixme
  ../../shared/services/miniflux.nix
  ../../shared/services/shiori.nix
  ../../shared/packages/graphics.nix
  ../../shared/services/virtualization.nix
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
  inputs.NixVirt.nixosModules.default
  {
    nixpkgs = {
      overlays = [
        (final: prev: {
          nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};

          # Override ollama-vulkan with version 0.13.3
          ollama-vulkan = prev.ollama-vulkan.overrideAttrs (old: {
            version = "0.15.6";
            src = builtins.fetchurl {
              # source
              url = "https://github.com/ollama/ollama/archive/refs/tags/v0.15.6.tar.gz";
              #rev = "v${version}";
              sha256 = "0wb3b18gdr88vpx8hvbycy2q2b1imbq1vsnpb97zk1yrkk8qyqn5";
            };
          });
        })
      ];
    };
    home-manager = {
      useGlobalPkgs = false;
      useUserPackages = true;
      users.kreator = import ../../users+home;
      backupFileExtension = "backup";
    };
  }
]
