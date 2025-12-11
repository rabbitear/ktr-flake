#!/usr/bin/env bash
# Create Fedora 43 base image with cloud-init

set -euo pipefail

TEMPLATE_DIR="/var/lib/libvirt/templates"
FEDORA_IMAGE="fedora-test.qcow2"
FEDORA_CLOUD_URL="http://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"

echo "Creating Fedora 43 base image..."

# Create template directory if it doesn't exist
sudo mkdir -p "$TEMPLATE_DIR"

# Download Fedora cloud image
echo "Downloading Fedora 43 cloud image..."
cd "$TEMPLATE_DIR"
sudo wget -O "$FEDORA_IMAGE" "$FEDORA_CLOUD_URL"

# Resize to 20GB
echo "Resizing image to 20GB..."
sudo qemu-img resize "$FEDORA_IMAGE" 20G

# Create cloud-init user-data file
cat > /tmp/user-data << 'EOF'
#cloud-config
hostname: fedora-test
manage_etc_hosts: true
users:
  - name: kreator
    groups: wheel,adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    plain_text_passwd: kreator
    shell: /bin/bash

packages:
  - qemu-guest-agent
  - spice-vdagent
  - net-tools
  - curl
  - wget
  - vim

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable spice-vdagent
  - systemctl start spice-vdagent
  - dnf update -y
EOF

# Create network-config file
cat > /tmp/network-config << 'EOF'
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF

# Create cloud-init ISO
echo "Creating cloud-init ISO..."
cloud-localds /tmp/fedora-cloud-init.iso /tmp/user-data /tmp/network-config

# Create a temporary VM for first boot setup
echo "Setting up base image with cloud-init..."
sudo virt-install \
  --name fedora-base-setup \
  --memory 2048 \
  --vcpus 2 \
  --disk path="$TEMPLATE_DIR/$FEDORA_IMAGE",format=qcow2 \
  --disk path=/tmp/fedora-cloud-init.iso,device=cdrom \
  --os-variant fedora43 \
  --graphics spice \
  --network bridge=virbr0 \
  --noautoconsole \
  --import

# Wait for cloud-init to complete
echo "Waiting for cloud-init to complete (90 seconds)..."
sleep 90

# Shutdown and cleanup
sudo virsh shutdown fedora-base-setup
sudo virsh undefine fedora-base-setup

# Clean up
rm -f /tmp/user-data /tmp/network-config /tmp/fedora-cloud-init.iso

echo "Fedora 43 base image created successfully at $TEMPLATE_DIR/$FEDORA_IMAGE"
echo "You can now create VMs using this as a backing image."
