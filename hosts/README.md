# Host Configurations

Per-host NixOS configurations. Each host directory contains:

- `configuration.nix`: Hardware and basic system configuration
- `default.nix`: Module imports, overlays, and host-specific settings
- `modules/`: Host-specific modules (optional)

Hosts: sasha (AMD GPU), yoshi (NVIDIA GPU), hacknet, otternode, wendy