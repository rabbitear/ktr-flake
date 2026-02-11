{ inputs }:
[
  ./configuration.nix
  ../../shared
  ./modules/ollama-vulkan.nix
  ../../shared/services/avahi.nix
  ../../shared/services/searx.nix
  ../../shared/services/openwebui.nix
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

          # Pin fastmcp to 2.11.0 to avoid breaking changes in 2.12.x
          python3Packages = prev.python3Packages.override {
            overrides = self: super: {
              fastmcp = super.fastmcp.overridePythonAttrs (old: {
                version = "2.11.0";
                src = prev.fetchFromGitHub {
                  owner = "jlowin";
                  repo = "fastmcp";
                  tag = "v2.11.0";
                  hash = "sha256-k96ki9ny1w5i47j9ry1762hhqf20fajnwkjg7vvh2l4h8sqnq6";
                };
              });
            };
          };
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
