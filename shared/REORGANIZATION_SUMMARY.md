# Shared Directory Reorganization Summary

## Overview
Reorganized the `shared/` directory to follow a cleaner, more modular structure with:
- **Core system config** in `core/`
- **Program configurations** in `programs/`
- **Package collections** in `packages/`
- **Service configurations** in `services/`

## New Structure

```
shared/
├── core/                          # Core system configuration
│   ├── base.nix                   # Base system (i18n, nix, user, printing, pipewire)
│   ├── security.nix                # GPG, SSH configuration
│   ├── networking.nix              # Tailscale, firewall, bluetooth
│   └── desktop.nix                # Display managers, window managers
├── packages/                      # Package collections
│   ├── cli.nix                    # Command-line tools
│   ├── tui.nix                    # Terminal UI apps + tmux
│   ├── dev.nix                    # Development tools
│   ├── desktop.nix                # Desktop packages (browsers, flatpak, etc)
│   ├── media.nix                  # Media applications
│   └── graphics.nix               # Graphics programs
├── programs/                      # Program configurations
│   ├── fonts.nix                  # Font configuration
│   ├── keyd.nix                   # Keyd remapping
│   ├── helix.nix                  # Helix editor + LSPs
│   └── gpg.nix                   # GPG configuration
├── services/                      # Service configurations
│   ├── avahi.nix                  # mDNS service
│   ├── jellyfin.nix               # Jellyfin media server
│   ├── miniflux.nix              # Miniflux feed reader
│   ├── openwebui.nix             # Open Web UI
│   ├── ollama.nix                # Ollama service
│   ├── searx.nix                 # Searx search
│   ├── shiori.nix                # Shiori bookmarks
│   ├── virtualization.nix         # Libvirt/Virt-manager
│   └── flatpak.nix              # Flatpak configuration
├── default.nix                    # Main entry point
├── sops.nix                      # SOPS secrets configuration
└── README.md                     # Documentation
```

## Changes Made

### Files Created
- `core/base.nix` - Consolidated from core-cli-utils.nix
- `core/security.nix` - Extracted from core-cli-utils.nix
- `core/networking.nix` - Extracted from default.nix
- `core/desktop.nix` - Extracted from default.nix
- `packages/cli.nix` - Consolidated from core-cli-utils.nix
- `packages/tui.nix` - Renamed from essential-tuis.nix
- `packages/dev.nix` - Renamed from core-tools.nix
- `packages/desktop.nix` - Consolidated from packages/desktop.nix + utils.nix
- `packages/media.nix` - Renamed from packages/media.nix
- `packages/graphics.nix` - Renamed from graphics-programs.nix
- `programs/fonts.nix` - Moved from root
- `programs/keyd.nix` - Moved from root
- `programs/helix.nix` - Renamed from helix-and-lsps.nix
- `programs/gpg.nix` - Created (moved from gpg.nix)
- `services/avahi.nix` - Renamed from chromecast.nix
- `services/jellyfin.nix` - Moved from root (fixed "ture" typo)
- `services/miniflux.nix` - Moved from root
- `services/openwebui.nix` - Moved from root
- `services/ollama.nix` - Renamed from ollama-rocm.nix
- `services/searx.nix` - Moved from root
- `services/shiori.nix` - Moved from root
- `services/virtualization.nix` - Moved from root
- `services/flatpak.nix` - Moved from root

### Files Removed
- `chromecast.nix` → `services/avahi.nix`
- `core-cli-utils.nix` → split into `core/base.nix`, `core/security.nix`, `packages/cli.nix`
- `core-tools.nix` → `packages/dev.nix`
- `essential-tuis.nix` → `packages/tui.nix`
- `flatpak.nix` → `services/flatpak.nix`
- `fonts.nix` → `programs/fonts.nix`
- `gpg.nix` → `programs/gpg.nix`
- `graphics-programs.nix` → `packages/graphics.nix`
- `helix-and-lsps.nix` → `programs/helix.nix`
- `jellyfin.nix` → `services/jellyfin.nix`
- `keyd.nix` → `programs/keyd.nix`
- `miniflux.nix` → `services/miniflux.nix`
- `ollama-rocm.nix` → `services/ollama.nix`
- `openwebui.nix` → `services/openwebui.nix`
- `packages/utils.nix` → merged into `packages/desktop.nix`
- `searx.nix` → `services/searx.nix`
- `shiori.nix` → `services/shiori.nix`
- `virtualization-README.md` → removed (documentation in README.md)
- `virtualization.nix` → `services/virtualization.nix`

### Files Modified
- `default.nix` - New streamlined version importing core, programs, packages, and services
- `hosts/sasha/default.nix` - Updated service paths to `services/`
- `hosts/wendy/default.nix` - Updated service paths to `services/`
- `hosts/jenny/default.nix` - Updated service paths to `services/`
- `hosts/yoshi/default.nix` - Updated service paths to `services/`

### Bugs Fixed
- Fixed typo in jellyfin.nix: `openFirewall = ture;` → `openFirewall = true;`

## Benefits

1. **Better organization** - Clear separation of concerns
2. **Smaller files** - Each file has a focused purpose
3. **Easier maintenance** - Easy to find and modify specific components
4. **Modular design** - Hosts can import specific services as needed
5. **Scalability** - Easy to add new packages, programs, or services

## Usage

Hosts continue to import `../../shared` for core functionality, and can add specific services from `services/` as needed:

```nix
{ inputs }:
[
  ./configuration.nix
  ../../shared
  ../../shared/services/jellyfin.nix
  ../../shared/services/searx.nix
  ...
]
```

## Testing

The new structure has been validated:
- All files parse correctly
- Default.nix imports resolve correctly
- Host configurations have been updated with new service paths
