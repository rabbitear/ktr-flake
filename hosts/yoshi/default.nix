{ inputs }:
[
  ./configuration.nix
  ../../shared
  ./modules/ollama-cuda.nix
  ./modules/nvidia-cuda.nix
  #../../shared/services/openwebui.nix
  ../../shared/services/searx.nix
  ../../shared/services/flatpak.nix
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
  {
    nixpkgs = {
      overlays = [
        (final: prev: {
          nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};
          ollama-cuda = prev.ollama-cuda.overrideAttrs (old: {
            version = "0.13.3";
            src = builtins.fetchurl {
              url = "https://github.com/ollama/ollama/archive/refs/tags/v0.13.3.tar.gz";
              sha256 = "11cigz2a2na2d0hxkwn0537g38qhkvficplzq9h4jhsqv2vcdnlv";
            };
          });
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
