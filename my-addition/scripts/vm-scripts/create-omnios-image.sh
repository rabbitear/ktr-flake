#!/usr/bin/env bash
# Create OmniOS r151056 base image with cloud-init

set -euo pipefail

TEMPLATE_DIR="/var/lib/libvirt/templates"
OMNIOS_IMAGE="omnios-test.qcow2"
OMNIOS_VMDK_URL="https://downloads.omnios.org/media/stable/omnios-r151056.cloud.vmdk"

echo "Creating OmniOS r151056 base image..."

# Create template directory if it doesn't exist
sudo mkdir -p "$TEMPLATE_DIR"

# Download OmniOS cloud VMDK image
echo "Downloading OmniOS r151056 cloud VMDK image..."
cd "$TEMPLATE_DIR"
sudo wget -O "omnios-r151056.vmdk" "$OMNIOS_VMDK_URL"

# Convert VMDK to QCOW2
echo "Converting VMDK to QCOW2 format..."
sudo qemu-img convert -f vmdk -O qcow2 "omnios-r151056.vmdk" "$OMNIOS_IMAGE"

# Remove the VMDK file
sudo rm "omnios-r151056.vmdk"

# Resize to 20GB
echo "Resizing image to 20GB..."
sudo qemu-img resize "$OMNIOS_IMAGE" 20G

# Create temp directory
TEMP_DIR=$(mktemp -d)

# Create cloud-init user-data file
cat > "$TEMP_DIR/user-data" << 'EOF'
#cloud-config
hostname: omnios-test
manage_etc_hosts: true
users:
  - name: kreator
    groups: sudo,adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    plain_text_passwd: kreator
    shell: /bin/bash
ssh_pwauth: true
chpasswd:
  list: |
    kreator:kreator
  expire: false

packages:
  - qemu-guest-agent
  - spice-vdagent
  - net-tools
  - curl
  - wget
  - vim

runcmd:
  - svcadm enable qemu-guest
  - svcadm enable spice-vdagent
EOF

# Create network-config file
cat > "$TEMP_DIR/network-config" << 'EOF'
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF

# Create cloud-init ISO
echo "Creating cloud-init ISO..."
cloud-localds "$TEMP_DIR/omnios-cloud-init.iso" "$TEMP_DIR/user-data" "$TEMP_DIR/network-config"

# Create a temporary VM for first boot setup
echo "Setting up base image with cloud-init..."
sudo virt-install \
  --name omnios-base-setup \
  --memory 2048 \
  --vcpus 2 \
  --disk path="$TEMPLATE_DIR/$OMNIOS_IMAGE",format=qcow2 \
  --disk path="$TEMP_DIR/omnios-cloud-init.iso",device=cdrom \
  --os-variant solaris11 \
  --graphics spice \
  --network bridge=virbr0 \
  --noautoconsole \
  --import

# Wait for cloud-init to complete
echo "Waiting for cloud-init to complete (90 seconds)..."
sleep 90

# Shutdown and cleanup
sudo virsh shutdown omnios-base-setup
sudo virsh undefine omnios-base-setup

# Clean up
rm -rf "$TEMP_DIR"

echo "OmniOS r151056 base image created successfully at $TEMPLATE_DIR/$OMNIOS_IMAGE"
echo "You can now create VMs using this as a backing image."