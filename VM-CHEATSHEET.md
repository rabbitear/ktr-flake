# VM Management Cheatsheet

## Daily VM Operations (as user `kreator`)

### 🚀 Start & Stop VMs
```bash
# Start a VM (system connection required)
virsh --connect qemu:///system start debian-test

# Stop a VM gracefully
virsh --connect qemu:///system shutdown debian-test

# Force stop (emergency)
virsh --connect qemu:///system destroy debian-test

# List all VMs
virsh --connect qemu:///system list --all
```

### 🖥️ Connect to VMs
```bash
# Graphical connection (SPICE) - local
virt-viewer --connect qemu:///system debian-test

# Graphical connection (SPICE) - remote over SSH
virt-viewer --connect qemu+ssh://kreator@sasha/system debian-test

# Serial console
virsh --connect qemu:///system console debian-test

# SSH (if VM has network)
ssh kreator@<vm-ip>
```

### 💾 VM Management
```bash
# Reboot a VM
virsh --connect qemu:///system reboot debian-test

# Pause/unpause
virsh --connect qemu:///system suspend debian-test
virsh --connect qemu:///system resume debian-test

# Save VM state to file
virsh --connect qemu:///system save debian-test ~/debian-test.state

# Restore from saved state
virsh --connect qemu:///system restore ~/debian-test.state
```

### 📊 VM Information
```bash
# VM details
virsh --connect qemu:///system dominfo debian-test

# VM resources usage
virsh --connect qemu:///system domstats debian-test

# Network interfaces
virsh --connect qemu:///system domiflist debian-test

# Disk devices
virsh --connect qemu:///system domblklist debian-test
```

### 🖧 Network Management
```bash
# List networks
virsh --connect qemu:///system net-list --all

# Start default network
virsh --connect qemu:///system net-start default

# Network info
virsh --connect qemu:///system net-info default

# DHCP leases (see VM IPs)
virsh --connect qemu:///system net-dhcp-leases default
```

### 💾 Storage Management
```bash
# List storage pools
virsh --connect qemu:///system pool-list --all

# Pool info
virsh --connect qemu:///system pool-info default

# List volumes in pool
virsh --connect qemu:///system vol-list default

# Volume info
virsh --connect qemu:///system vol-info debian-test.qcow2 default

# Clone a volume
virsh --connect qemu:///system vol-clone debian-test.qcow2 debian-test-clone.qcow2 default
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
virsh --connect qemu:///system edit debian-test

# Dump current XML
virsh --connect qemu:///system dumpxml debian-test > debian-test-current.xml

# Define VM from XML file
virsh --connect qemu:///system define debian-test-new.xml
```

## 🐛 Troubleshooting

### Common Issues
```bash
# If VM won't start, check logs
virsh --connect qemu:///system start debian-test --verbose
journalctl -u libvirtd -f

# If network not working
virsh --connect qemu:///system net-start default
virsh --connect qemu:///system net-autostart default

# If disk issues
virsh --connect qemu:///system vol-refresh default
virsh --connect qemu:///system pool-refresh default

# Reset libvirt completely
sudo systemctl restart libvirtd
```

### VM Console Access
```bash
# Get serial console (if configured)
virsh --connect qemu:///system console debian-test

# Emergency access - connect to display
virt-viewer --connect qemu:///system debian-test

# Check VM logs
virsh --connect qemu:///system domxml-from-native debian-test
```

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `virsh --connect qemu:///system list --all` | Show all VMs |
| `virsh --connect qemu:///system start <name>` | Start VM |
| `virsh --connect qemu:///system shutdown <name>` | Stop VM gracefully |
| `virt-viewer --connect qemu+ssh://kreator@sasha/system <name>` | Remote graphical access |
| `virsh --connect qemu:///system console <name>` | Text console |
| `virsh --connect qemu:///system edit <name>` | Edit configuration |
| `virsh --connect qemu:///system net-dhcp-leases default` | Find VM IPs |
| `sudo nixos-rebuild switch` | Apply config changes |

## 🎯 Typical Workflow

1. **Daily Use**: `virsh --connect qemu:///system start debian-test` → `virt-viewer --connect qemu:///system debian-test`
2. **Remote Access**: `virt-viewer --connect qemu+ssh://kreator@sasha/system debian-test`
3. **Create New VM**: Clone template → `virsh --connect qemu:///system define` → `virsh --connect qemu:///system start`
4. **Configuration Changes**: Edit `virtualization.nix` → `sudo nixos-rebuild switch`
5. **Troubleshooting**: Check `virsh --connect qemu:///system list`, `journalctl -u libvirtd`

## 📁 Important Paths

- **VM Configs**: `/etc/libvirt/qemu/`
- **VM Disks**: `/var/lib/libvirt/images/`
- **Base Images**: `/var/lib/libvirt/templates/`
- **Nix Config**: `~/docs/ktr-flake/programs+services/virtualization.nix`
- **Scripts**: `~/docs/ktr-flake/my-addition/vm-scripts/`

## 🔗 Remote Access

### SSH Tunneling for VM Access
```bash
# From any machine with SSH access to sasha
virt-viewer --connect qemu+ssh://kreator@sasha/system debian-test
virt-viewer --connect qemu+ssh://kreator@sasha/system fedora-test

# Alternative: Set up SSH config in ~/.ssh/config
Host sasha-vm
    HostName sasha
    User kreator
    # Add your SSH key config here

# Then use:
virt-viewer --connect qemu+ssh://sasha-vm/system debian-test
```

### Current VMs Available
- **debian-test**: Debian 13 with QEMU guest agent, SPICE tools
- **fedora-test**: Fedora 43 with QEMU guest agent, SPICE tools
- Both configured with 2 vCPUs, 2GB RAM, 20GB disk, SPICE graphics