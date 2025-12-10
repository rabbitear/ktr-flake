# VM Management Cheatsheet

## Daily VM Operations (as user `kreator`)

### 🚀 Start & Stop VMs
```bash
# Start a VM
virsh start debian-test

# Stop a VM gracefully
virsh shutdown debian-test

# Force stop (emergency)
virsh destroy debian-test

# List all VMs
virsh list --all
```

### 🖥️ Connect to VMs
```bash
# Graphical connection (SPICE)
virt-viewer debian-test

# Serial console
virsh console debian-test

# SSH (if VM has network)
ssh kreator@<vm-ip>
```

### 💾 VM Management
```bash
# Reboot a VM
virsh reboot debian-test

# Pause/unpause
virsh suspend debian-test
virsh resume debian-test

# Save VM state to file
virsh save debian-test ~/debian-test.state

# Restore from saved state
virsh restore ~/debian-test.state
```

### 📊 VM Information
```bash
# VM details
virsh dominfo debian-test

# VM resources usage
virsh domstats debian-test

# Network interfaces
virsh domiflist debian-test

# Disk devices
virsh domblklist debian-test
```

### 🖧 Network Management
```bash
# List networks
virsh net-list --all

# Start default network
virsh net-start default

# Network info
virsh net-info default

# DHCP leases (see VM IPs)
virsh net-dhcp-leases default
```

### 💾 Storage Management
```bash
# List storage pools
virsh pool-list --all

# Pool info
virsh pool-info default

# List volumes in pool
virsh vol-list default

# Volume info
virsh vol-info debian-test.qcow2 default

# Clone a volume
virsh vol-clone debian-test.qcow2 debian-test-clone.qcow2 default
```

## 🛠️ VM Creation & Templates

### Create New VM from Template
```bash
# Create new VM based on debian template
virt-install \
  --name debian-test-2 \
  --memory 2048 \
  --vcpus 2 \
  --disk /var/lib/libvirt/images/debian-test-2.qcow2,size=20 \
  --backing-store /var/lib/libvirt/templates/debian-test.qcow2 \
  --os-variant debian12 \
  --network network=default \
  --graphics spice \
  --import
```

### Create Base Images
```bash
# Create all base images
./my-addition/vm-scripts/create-all-images.sh

# Create specific OS image
./my-addition/vm-scripts/create-debian-image.sh
./my-addition/vm-scripts/create-fedora-image.sh
./my-addition/vm-scripts/create-openbsd-image.sh
```

## 🔧 Configuration Management

### Apply Nix Configuration Changes
```bash
# After modifying virtualization.nix
sudo nixos-rebuild switch

# Test changes without applying
sudo nixos-rebuild test
```

### Edit VM Configuration
```bash
# Edit XML definition (advanced)
virsh edit debian-test

# Dump current XML
virsh dumpxml debian-test > debian-test-current.xml

# Define VM from XML file
virsh define debian-test-new.xml
```

## 🐛 Troubleshooting

### Common Issues
```bash
# If VM won't start, check logs
virsh start debian-test --verbose
journalctl -u libvirtd -f

# If network not working
virsh net-start default
virsh net-autostart default

# If disk issues
virsh vol-refresh default
virsh pool-refresh default

# Reset libvirt completely
sudo systemctl restart libvirtd
```

### VM Console Access
```bash
# Get serial console (if configured)
virsh console debian-test

# Emergency access - connect to display
virt-viewer --connect qemu:///system debian-test

# Check VM logs
virsh domxml-from-native debian-test
```

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `virsh list --all` | Show all VMs |
| `virsh start <name>` | Start VM |
| `virsh shutdown <name>` | Stop VM gracefully |
| `virt-viewer <name>` | Graphical access |
| `virsh console <name>` | Text console |
| `virsh edit <name>` | Edit configuration |
| `virsh net-dhcp-leases default` | Find VM IPs |
| `sudo nixos-rebuild switch` | Apply config changes |

## 🎯 Typical Workflow

1. **Daily Use**: `virsh start debian-test` → `virt-viewer debian-test`
2. **Create New VM**: Clone template → `virsh define` → `virsh start`
3. **Configuration Changes**: Edit `virtualization.nix` → `sudo nixos-rebuild switch`
4. **Troubleshooting**: Check `virsh list`, `journalctl -u libvirtd`

## 📁 Important Paths

- **VM Configs**: `/etc/libvirt/qemu/`
- **VM Disks**: `/var/lib/libvirt/images/`
- **Base Images**: `/var/lib/libvirt/templates/`
- **Nix Config**: `~/docs/ktr-flake/programs+services/virtualization.nix`
- **Scripts**: `~/docs/ktr-flake/my-addition/vm-scripts/`