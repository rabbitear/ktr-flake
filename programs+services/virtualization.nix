# Virtualization with NixVirt
# ktr - I let glm-4.6 do this file
#       now I'm looking it over, there are some oddnesses
#       but this seems to be the par for this ai course :)
#     - TODO: Need to go thru this, some later time!!
#       its not too too bad, but I might want to use the
#       NixVirt formats instead of plain xml.
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
  
  # VM definitions using NixVirt declarative attribute sets
  virtualisation.libvirt.connections."qemu:///system".domains = [
    {
      definition = nixvirtlib.domain.writeXML {
        type = "kvm";
        name = "debian-test";
        uuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";
        memory = { unit = "GiB"; count = 2; };
        currentMemory = { unit = "GiB"; count = 2; };
        vcpu = { placement = "static"; count = 2; };
        os = {
          arch = "x86_64";
          machine = "pc-q35-8.2";
          type = "hvm";
          boot = { dev = "hd"; };
        };
        features = {
          acpi = {};
          apic = {};
          vmport = { state = "off"; };
        };
        cpu = { mode = "host-model"; check = "partial"; };
        clock = {
          offset = "utc";
          timer = [
            { name = "rtc"; tickpolicy = "catchup"; track = "guest"; }
            { name = "pit"; tickpolicy = "delay"; }
            { name = "hpet"; present = "no"; }
          ];
        };
        pm = {
          suspend-to-mem = { enabled = "no"; };
          suspend-to-disk = { enabled = "no"; };
        };
        devices = {
          emulator = "/run/current-system/sw/bin/qemu-system-x86_64";
          disk = {
            type = "file";
            device = "disk";
            driver = { name = "qemu"; type = "qcow2"; };
            source = { file = "/var/lib/libvirt/images/debian-test.qcow2"; };
            target = { dev = "vda"; bus = "virtio"; };
            address = { type = "pci"; domain = "0x0000"; bus = "0x04"; slot = "0x00"; function = "0x0"; };
          };
          controller = [
            {
              type = "usb";
              index = 0;
              model = "qemu-xhci";
              ports = 15;
              address = { type = "pci"; domain = "0x0000"; bus = "0x02"; slot = "0x00"; function = "0x0"; };
            }
            { type = "pci"; index = 0; model = "pcie-root"; }
            {
              type = "pci";
              index = 1;
              model = "pcie-root-port";
              target = { chassis = 1; port = "0x8"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x0"; multifunction = "on"; };
            }
            {
              type = "pci";
              index = 2;
              model = "pcie-root-port";
              target = { chassis = 2; port = "0x9"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x1"; };
            }
            {
              type = "pci";
              index = 3;
              model = "pcie-root-port";
              target = { chassis = 3; port = "0xa"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x2"; };
            }
            {
              type = "pci";
              index = 4;
              model = "pcie-root-port";
              target = { chassis = 4; port = "0xb"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x3"; };
            }
            {
              type = "pci";
              index = 5;
              model = "pcie-root-port";
              target = { chassis = 5; port = "0xc"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x4"; };
            }
            {
              type = "pci";
              index = 6;
              model = "pcie-root-port";
              target = { chassis = 6; port = "0xd"; };
              address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x01"; function = "0x5"; };
            }
            {
              type = "virtio-serial";
              index = 0;
              address = { type = "pci"; domain = "0x0000"; bus = "0x03"; slot = "0x00"; function = "0x0"; };
            }
          ];
          interface = {
            type = "network";
            mac = { address = "52:54:00:ab:cd:ef"; };
            source = { network = "default"; };
            model = { type = "virtio"; };
            address = { type = "pci"; domain = "0x0000"; bus = "0x01"; slot = "0x00"; function = "0x0"; };
          };
          serial = {
            type = "pty";
            target = {
              type = "isa-serial";
              port = 0;
              model = { name = "isa-serial"; };
            };
          };
          console = {
            type = "pty";
            target = { type = "serial"; port = 0; };
          };
          channel = {
            type = "spicevmc";
            target = { type = "virtio"; name = "com.redhat.spice.0"; };
            address = { type = "virtio-serial"; controller = 0; bus = 0; port = 1; };
          };
          input = [
            {
              type = "tablet";
              bus = "usb";
              address = { type = "usb"; bus = 0; port = 1; };
            }
            { type = "mouse"; bus = "ps2"; }
            { type = "keyboard"; bus = "ps2"; }
          ];
          graphics = {
            type = "spice";
            autoport = "yes";
            listen = { type = "address"; };
            image = { compression = "off"; };
          };
          sound = {
            model = "ich9";
            address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x1b"; function = "0x0"; };
          };
          video = {
            model = {
              type = "virtio";
              heads = 1;
              primary = "yes";
              acceleration = { accel3d = "no"; };
            };
            address = { type = "pci"; domain = "0x0000"; bus = "0x00"; slot = "0x02"; function = "0x0"; };
          };
          redirdev = {
            bus = "usb";
            type = "spicevmc";
            address = { type = "usb"; bus = 0; port = 2; };
          };
          memballoon = {
            model = "virtio";
            address = { type = "pci"; domain = "0x0000"; bus = "0x05"; slot = "0x00"; function = "0x0"; };
          };
        };
      };
      active = false;
    }
  ];
}
