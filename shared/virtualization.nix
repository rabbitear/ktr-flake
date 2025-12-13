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
  
  # Network definitions
  virtualisation.libvirt.connections."qemu:///system".networks = [
    {
      definition = nixvirtlib.network.writeXML (nixvirtlib.network.templates.bridge {
        name = "default";
        uuid = "c4acfd00-4597-41c7-a48e-e2302234fa89";
        subnet_byte = 74;
      });
      active = true;
    }
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
          vmport = { state = false; };
        };
        cpu = { mode = "host-model"; check = "partial"; };
        clock = {
          offset = "utc";
          timer = [
            { name = "rtc"; tickpolicy = "catchup"; track = "guest"; }
            { name = "pit"; tickpolicy = "delay"; }
            { name = "hpet"; present = false; }
          ];
        };
        pm = {
          suspend-to-mem = { enabled = false; };
          suspend-to-disk = { enabled = false; };
        };
        devices = {
          emulator = "/run/current-system/sw/bin/qemu-system-x86_64";
          disk = {
            type = "file";
            device = "disk";
            driver = { name = "qemu"; type = "qcow2"; };
            source = { file = "/var/lib/libvirt/images/debian-test.qcow2"; };
            target = { dev = "vda"; bus = "virtio"; };
            address = { type = "pci"; domain = 0; bus = 4; slot = 0; function = 0; };
          };
          controller = [
            {
              type = "usb";
              index = 0;
              model = "qemu-xhci";
              ports = 15;
              address = { type = "pci"; domain = 0; bus = 2; slot = 0; function = 0; };
            }
            { type = "pci"; index = 0; model = "pcie-root"; }
            {
              type = "pci";
              index = 1;
              model = "pcie-root-port";
              target = { chassis = 1; port = 8; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 0; multifunction = true; };
            }
            {
              type = "pci";
              index = 2;
              model = "pcie-root-port";
              target = { chassis = 2; port = 9; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 1; };
            }
            {
              type = "pci";
              index = 3;
              model = "pcie-root-port";
              target = { chassis = 3; port = 10; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 2; };
            }
            {
              type = "pci";
              index = 4;
              model = "pcie-root-port";
              target = { chassis = 4; port = 11; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 3; };
            }
            {
              type = "pci";
              index = 5;
              model = "pcie-root-port";
              target = { chassis = 5; port = 12; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 4; };
            }
            {
              type = "pci";
              index = 6;
              model = "pcie-root-port";
              target = { chassis = 6; port = 13; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 5; };
            }
            {
              type = "virtio-serial";
              index = 0;
              address = { type = "pci"; domain = 0; bus = 3; slot = 0; function = 0; };
            }
          ];
          interface = {
            type = "network";
            mac = { address = "52:54:00:ab:cd:ef"; };
            source = { network = "default"; };
            model = { type = "virtio"; };
            address = { type = "pci"; domain = 0; bus = 1; slot = 0; function = 0; };
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
            autoport = true;
            #gl = { enable = true; };
            listen = { type = "address"; };
            image = { compression = false; };
          };
          sound = {
            model = "ich9";
            address = { type = "pci"; domain = 0; bus = 0; slot = 27; function = 0; };
          };
          video = {
            model = {
              type = "virtio";
              heads = 1;
              primary = true;
              acceleration = { accel3d = false; };
            };
            address = { type = "pci"; domain = 0; bus = 0; slot = 2; function = 0; };
          };
          redirdev = {
            bus = "usb";
            type = "spicevmc";
            address = { type = "usb"; bus = 0; port = 2; };
          };
          memballoon = {
            model = "virtio";
            address = { type = "pci"; domain = 0; bus = 5; slot = 0; function = 0; };
          };
        };
      };
      active = false;
    }
    {
      definition = nixvirtlib.domain.writeXML {
        type = "kvm";
        name = "fedora-test";
        uuid = "b2c3d4e5-f6a7-8901-bcde-f12345678901";
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
          vmport = { state = false; };
        };
        cpu = { mode = "host-model"; check = "partial"; };
        clock = {
          offset = "utc";
          timer = [
            { name = "rtc"; tickpolicy = "catchup"; track = "guest"; }
            { name = "pit"; tickpolicy = "delay"; }
            { name = "hpet"; present = false; }
          ];
        };
        pm = {
          suspend-to-mem = { enabled = false; };
          suspend-to-disk = { enabled = false; };
        };
        devices = {
          emulator = "/run/current-system/sw/bin/qemu-system-x86_64";
          disk = {
            type = "file";
            device = "disk";
            driver = { name = "qemu"; type = "qcow2"; };
            source = { file = "/var/lib/libvirt/images/fedora-test.qcow2"; };
            target = { dev = "vda"; bus = "virtio"; };
            address = { type = "pci"; domain = 0; bus = 4; slot = 0; function = 0; };
          };
          controller = [
            {
              type = "usb";
              index = 0;
              model = "qemu-xhci";
              ports = 15;
              address = { type = "pci"; domain = 0; bus = 2; slot = 0; function = 0; };
            }
            { type = "pci"; index = 0; model = "pcie-root"; }
            {
              type = "pci";
              index = 1;
              model = "pcie-root-port";
              target = { chassis = 1; port = 8; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 0; multifunction = true; };
            }
            {
              type = "pci";
              index = 2;
              model = "pcie-root-port";
              target = { chassis = 2; port = 9; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 1; };
            }
            {
              type = "pci";
              index = 3;
              model = "pcie-root-port";
              target = { chassis = 3; port = 10; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 2; };
            }
            {
              type = "pci";
              index = 4;
              model = "pcie-root-port";
              target = { chassis = 4; port = 11; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 3; };
            }
            {
              type = "pci";
              index = 5;
              model = "pcie-root-port";
              target = { chassis = 5; port = 12; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 4; };
            }
            {
              type = "pci";
              index = 6;
              model = "pcie-root-port";
              target = { chassis = 6; port = 13; };
              address = { type = "pci"; domain = 0; bus = 0; slot = 1; function = 5; };
            }
            {
              type = "virtio-serial";
              index = 0;
              address = { type = "pci"; domain = 0; bus = 3; slot = 0; function = 0; };
            }
          ];
          interface = {
            type = "network";
            mac = { address = "52:54:00:cd:ef:ab"; };
            source = { network = "default"; };
            model = { type = "virtio"; };
            address = { type = "pci"; domain = 0; bus = 1; slot = 0; function = 0; };
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
            autoport = true;
            #gl = { enable = true; };
            listen = { type = "address"; };
            image = { compression = false; };
          };
          sound = {
            model = "ich9";
            address = { type = "pci"; domain = 0; bus = 0; slot = 27; function = 0; };
          };
          video = {
            model = {
              type = "virtio";
              heads = 1;
              primary = true;
              acceleration = { accel3d = false; };
            };
            address = { type = "pci"; domain = 0; bus = 0; slot = 2; function = 0; };
          };
          redirdev = {
            bus = "usb";
            type = "spicevmc";
            address = { type = "usb"; bus = 0; port = 2; };
          };
          memballoon = {
            model = "virtio";
            address = { type = "pci"; domain = 0; bus = 5; slot = 0; function = 0; };
          };
        };
      };
      active = false;
    }
  ];
}
