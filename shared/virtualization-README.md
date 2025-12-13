# NixVirt Virtualization Setup

## What We Implemented

### 1. **Virtualization Module** (`programs+services/virtualization.nix`)
- Enabled libvirt daemon with NixVirt integration
- Added user `kreator` to required groups: `libvirtd`, `kvm`, `input`
- Installed essential packages: `virt-manager`, `virt-viewer`, `libvirt`, `qemu`, `spice`, `spice-gtk`
- Created template directory structure
- Defined declarative VM configurations using XML

### 2. **Base Image Scripts** (`my-addition/vm-scripts/`)
- `create-debian-image.sh` - Automated Debian 12 cloud image setup with cloud-init
- `create-fedora-image.sh` - Automated Fedora 40 cloud image setup with cloud-init  
- `create-openbsd-image.sh` - Manual OpenBSD 7.5 installation process
- `create-all-images.sh` - Master script to create all base images

### 3. **VM Configuration**
- **debian-test**: 2GB RAM, 20GB disk, SPICE graphics, VirtIO drivers
- Ready for additional VMs (fedora-test, openbsd-test) when needed
- Uses efficient backing store approach for thin clones

### 4. **Nix Integration**
- Added virtualization module to sasha's configuration
- All VMs are declaratively managed
- Changes applied via `nixos-rebuild switch`

## Architecture

```
/var/lib/libvirt/
├── images/          # VM disk images (thin clones)
├── templates/       # Base images (read-only)
└── ...

VMs use backing stores:
templates/debian-test.qcow2 (base) ← images/debian-test.qcow2 (working)
```

## Benefits

- **Declarative**: VM configs in code, reproducible
- **Atomic**: All VMs created/updated together  
- **Rollback**: Revert to previous VM configurations
- **User-managed**: `kreator` can manage VMs without root
- **Efficient**: Backing stores save disk space and speed up creation

## Next Steps

1. Run `./my-addition/vm-scripts/create-all-images.sh` to create base images
2. Start using VMs with `virsh start debian-test`
3. Access with `virt-viewer debian-test`
4. Modify VM configs in `virtualization.nix` as needed