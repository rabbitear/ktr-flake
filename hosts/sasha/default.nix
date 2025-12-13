{ inputs }:
[
  ./configuration.nix
  ../../shared
  ./modules/ollama-vulkan.nix
  ../../shared/chromecast.nix
  ../../shared/searx.nix
  ../../shared/openwebui.nix
  ../../shared/graphics-programs.nix
  ../../shared/virtualization.nix
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
  inputs.NixVirt.nixosModules.default
  {
    nixpkgs.overlays = [
      (final: prev: {
        nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};
        # Override ollama-vulkan with version 0.13.3
        ollama-vulkan = prev.ollama-vulkan.overrideAttrs (old: {
          version = "0.13.3";
          src = builtins.fetchurl {
            # source
            url = "https://github.com/ollama/ollama/archive/refs/tags/v0.13.3.tar.gz";
            sha256 = "11cigz2a2na2d0hxkwn0537g38qhkvficplzq9h4jhsqv2vcdnlv";
            # binary
            #url = "https://github.com/ollama/ollama/releases/download/v0.13.3/ollama-linux-amd64.tgz";
            #sha256 = "1sy60c8fq0pq81yl6z1r5r19mvcl6i55c7akqm0kc06drksd18vh";
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
                #tag = "v${version}";
                tag = "v2.11.0";
                hash = "sha256-k96ki9ny1w5i47j9ry1762hhqf20fajnwkjg7vvh2l4h8sqnq6";
              };
            });
          };
        });
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