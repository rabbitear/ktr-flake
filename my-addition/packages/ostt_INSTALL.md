# NixOS Configuration

Add to your NixOS configuration (e.g., `/etc/nixos/configuration.nix`):

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./path/to/package.nix {})
  ];
}
```

# Home Manager Configuration

Add to your Home Manager configuration:

```nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.callPackage ./path/to/package.nix {})
  ];
}
```

# Using Flake

Build and install with flake:

```bash
nix build .#ostt
./result/bin/ostt
```

Add to your flake-based system config:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ostt-flake.url = "path:/home/kreator/docs/code/vibe-ostt";
  };

  outputs = { self, nixpkgs, ostt-flake, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ config, ... }: {
          environment.systemPackages = [ ostt-flake.packages.x86_64-linux.default ];
        })
      ];
    };
  };
}
```
