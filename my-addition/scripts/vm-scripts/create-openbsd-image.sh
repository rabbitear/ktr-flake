#!/usr/bin/env bash
# Create OpenBSD 7.8 base image (manual install process)

set -euo pipefail

TEMPLATE_DIR="/var/lib/libvirt/templates"
OPENBSD_IMAGE="openbsd-test.qcow2"
OPENBSD_INSTALL_URL="https://cdn.openbsd.org/pub/OpenBSD/7.8/amd64/install78.iso"

echo "Creating OpenBSD 7.8 base image..."
echo "NOTE: This requires manual installation. Follow the prompts."

# Create template directory if it doesn't exist
sudo mkdir -p "$TEMPLATE_DIR"

# Download OpenBSD install ISO
echo "Downloading OpenBSD 7.8 install ISO..."
cd "$TEMPLATE_DIR"
sudo wget -O "openbsd75.iso" "$OPENBSD_INSTALL_URL"

# Create empty disk image
echo "Creating 15GB disk image..."
sudo qemu-img create -f qcow2 "$OPENBSD_IMAGE" 15G

echo "Starting OpenBSD installation..."
echo "You will need to:"
echo "1. Choose 'Install' from the boot menu"
echo "2. Accept defaults for most options"
echo "3. Set hostname: openbsd-test"
echo "4. Configure network: DHCP (em0)"
echo "5. Set root password: kreator"
echo "6. Create user 'kreator' with password 'kreator'"
echo "7. Install to: sd0 (the whole disk)"
echo "8. When asked about location, choose 'Install sets from cd0'"
echo "9. After installation, halt the system"

# Start installation
sudo virt-install \
  --name openbsd-base-setup \
  --memory 1024 \
  --vcpus 1 \
  --disk path="$TEMPLATE_DIR/$OPENBSD_IMAGE",format=qcow2 \
  --disk path="$TEMPLATE_DIR/openbsd75.iso",device=cdrom \
  --os-variant openbsd6 \
  --graphics spice \
  --network bridge=virbr0 \
  --boot cdrom \
  --noautoconsole

echo "OpenBSD VM started. Use virt-viewer to complete installation:"
echo "virt-viewer openbsd-base-setup"
echo ""
echo "After installation is complete and VM is shut down:"
echo "sudo virsh undefine openbsd-base-setup"
echo ""
echo "Then run this script again to clean up the ISO file."
