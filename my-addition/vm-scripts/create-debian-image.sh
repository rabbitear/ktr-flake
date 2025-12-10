#!/usr/bin/env bash
# Create Debian 12 base image with cloud-init

set -euo pipefail

TEMPLATE_DIR="/var/lib/libvirt/templates"
DEBIAN_IMAGE="debian-test.qcow2"
DEBIAN_CLOUD_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"

echo "Creating Debian 13 base image..."

# Create template directory if it doesn't exist
sudo mkdir -p "$TEMPLATE_DIR"

# Download Debian cloud image
echo "Downloading Debian 13 cloud image..."
cd "$TEMPLATE_DIR"
sudo wget -O "$DEBIAN_IMAGE" "$DEBIAN_CLOUD_URL"

# Resize to 20GB
echo "Resizing image to 20GB..."
sudo qemu-img resize "$DEBIAN_IMAGE" 20G

# Create cloud-init user-data file
cat > /tmp/user-data << 'EOF'
#cloud-config
hostname: debian-test
manage_etc_hosts: true
users:
  - name: kreator
    groups: sudo,adm,cdrom,plugdev,lpadmin,sambashare
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
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable spice-vdagent
  - systemctl start spice-vdagent
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
sudo apt-get install -y cloud-image-utils || sudo pacman -S cloud-utils || true
sudo cloud-localds /tmp/debian-cloud-init.iso /tmp/user-data /tmp/network-config

# Create a temporary VM for first boot setup
echo "Setting up base image with cloud-init..."
sudo virt-install \
  --name debian-base-setup \
  --memory 2048 \
  --vcpus 2 \
  --disk path="$TEMPLATE_DIR/$DEBIAN_IMAGE",format=qcow2 \
  --disk path=/tmp/debian-cloud-init.iso,device=cdrom \
  --os-variant debian13 \
  --graphics spice \
  --network bridge=virbr0 \
  --noautoconsole \
  --import

# Wait for cloud-init to complete
echo "Waiting for cloud-init to complete (60 seconds)..."
sleep 60

# Shutdown and cleanup
sudo virsh shutdown debian-base-setup
sudo virsh undefine debian-base-setup

# Clean up
rm -f /tmp/user-data /tmp/network-config /tmp/debian-cloud-init.iso

echo "Debian 13 base image created successfully at $TEMPLATE_DIR/$DEBIAN_IMAGE"
echo "You can now create VMs using this as a backing image."
