# Virtualization with NixVirt
{ config, lib, pkgs, inputs, ... }:

with lib;

let
  nixvirtlib = inputs.NixVirt.lib;
  
in {
  # Enable libvirt daemon
  virtualisation.libvirtd.enable = true;
  
  # Enable NixVirt
  virtualisation.libvirt.enable = true;
  
  # Enable SPICE for remote display
  virtualisation.spiceUSBRedirection.enable = true;
  
  # User permissions for kreator
  users.users.kreator.extraGroups = [ "libvirtd" "kvm" "input" ];
  
  # Required packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    libvirt
    qemu
    spice
    spice-gtk
  ];
  
  # Create directories for templates
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/templates 0755 root root -"
  ];
  
  # Simple VM definitions using manual XML files for now
  # We'll migrate to NixVirt templates once basic setup works
  virtualisation.libvirt.connections."qemu:///system".domains = [
    {
      definition = pkgs.writeText "debian-test.xml" ''
        <domain type='kvm'>
          <name>debian-test</name>
          <uuid>a1b2c3d4-e5f6-7890-abcd-ef1234567890</uuid>
          <memory unit='GiB'>2</memory>
          <currentMemory unit='GiB'>2</currentMemory>
          <vcpu placement='static'>2</vcpu>
          <os>
            <type arch='x86_64' machine='pc-q35-8.2'>hvm</type>
            <boot dev='hd'/>
          </os>
          <features>
            <acpi/>
            <apic/>
            <vmport state='off'/>
          </features>
          <cpu mode='host-model' check='partial'/>
          <clock offset='utc'>
            <timer name='rtc' tickpolicy='catchup' track='guest'/>
            <timer name='pit' tickpolicy='delay'/>
            <timer name='hpet' present='no'/>
          </clock>
          <pm>
            <suspend-to-mem enabled='no'/>
            <suspend-to-disk enabled='no'/>
          </pm>
          <devices>
            <emulator>/run/current-system/sw/bin/qemu-system-x86_64</emulator>
            <disk type='file' device='disk'>
              <driver name='qemu' type='qcow2'/>
              <source file='/var/lib/libvirt/images/debian-test.qcow2'/>
              <target dev='vda' bus='virtio'/>
              <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
            </disk>
            <controller type='usb' index='0' model='qemu-xhci' ports='15'>
              <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
            </controller>
            <controller type='pci' index='0' model='pcie-root'/>
            <controller type='pci' index='1' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='1' port='0x8'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0' multifunction='on'/>
            </controller>
            <controller type='pci' index='2' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='2' port='0x9'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
            </controller>
            <controller type='pci' index='3' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='3' port='0xa'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
            </controller>
            <controller type='pci' index='4' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='4' port='0xb'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x3'/>
            </controller>
            <controller type='pci' index='5' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='5' port='0xc'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x4'/>
            </controller>
            <controller type='pci' index='6' model='pcie-root-port'>
              <model name='pcie-root-port'/>
              <target chassis='6' port='0xd'/>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x5'/>
            </controller>
            <controller type='virtio-serial' index='0'>
              <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
            </controller>
            <interface type='network'>
              <mac address='52:54:00:ab:cd:ef'/>
              <source network='default'/>
              <model type='virtio'/>
              <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
            </interface>
            <serial type='pty'>
              <target type='isa-serial' port='0'>
                <model name='isa-serial'/>
              </target>
            </serial>
            <console type='pty'>
              <target type='serial' port='0'/>
            </console>
            <channel type='spicevmc'>
              <target type='virtio' name='com.redhat.spice.0'/>
              <address type='virtio-serial' controller='0' bus='0' port='1'/>
            </channel>
            <input type='tablet' bus='usb'>
              <address type='usb' bus='0' port='1'/>
            </input>
            <input type='mouse' bus='ps2'/>
            <input type='keyboard' bus='ps2'/>
            <graphics type='spice' autoport='yes'>
              <listen type='address'/>
              <image compression='off'/>
            </graphics>
            <sound model='ich9'>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x1b' function='0x0'/>
            </sound>
            <video>
              <model type='virtio' heads='1' primary='yes'>
                <acceleration accel3d='no'/>
              </model>
              <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
            </video>
            <redirdev bus='usb' type='spicevmc'>
              <address type='usb' bus='0' port='2'/>
            </redirdev>
            <memballoon model='virtio'>
              <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
            </memballoon>
          </devices>
        </domain>
      '';
      active = false;
    }
  ];
}