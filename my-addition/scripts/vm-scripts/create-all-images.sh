#!/usr/bin/env bash
# Create all base images for VM templates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating all VM base images..."
echo "This will take some time and requires internet connection."
echo ""

# Check if user is in libvirtd group
if ! groups | grep -q libvirtd; then
    echo "Error: User not in libvirtd group. Please run:"
    echo "sudo usermod -a -G libvirtd,kvm,input \$USER"
    echo "Then log out and log back in."
    exit 1
fi

# Check if libvirtd is running
if ! systemctl is-active --quiet libvirtd; then
    echo "Starting libvirtd service..."
    sudo systemctl start libvirtd
fi

echo "Creating Debian 12 image..."
"$SCRIPT_DIR/create-debian-image.sh"

echo ""
echo "Creating Fedora 40 image..."
"$SCRIPT_DIR/create-fedora-image.sh"

echo ""
echo "For OpenBSD, manual installation required:"
echo "$SCRIPT_DIR/create-openbsd-image.sh"

echo ""
echo "Base images creation completed!"
echo "You can now start using the VMs with:"
echo "  virsh start debian-test"
echo "  virsh start fedora-test"
echo "  virt-viewer debian-test"
echo "  virt-viewer fedora-test"