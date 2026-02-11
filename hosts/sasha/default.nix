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
          blender-mcp = inputs.self.packages.${prev.system}.blender-mcp;

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
