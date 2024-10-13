locals {
  virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.1.21/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-2 = {
      ipv4_address = "192.168.1.22/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-3 = {
      ipv4_address = "192.168.1.23/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-4 = {
      ipv4_address = "192.168.1.24/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-5 = {
      ipv4_address = "192.168.1.25/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-6 = {
      ipv4_address = "192.168.1.26/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-7 = {
      ipv4_address = "192.168.1.27/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-8 = {
      ipv4_address = "192.168.1.28/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-9 = {
      ipv4_address = "192.168.1.29/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-10 = {
      ipv4_address = "192.168.1.30/24"
      cpu_cores    = 1
      memory       = 1024
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s" {
  for_each = local.virtual_machines

  name      = each.key
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = each.value.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = "local:iso/nocloud-amd64.img"
    file_format  = "raw"
    interface    = "scsi0"
    iothread     = true
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = each.value.ipv4_address
        gateway = "192.168.1.1"
      }
    }
  }

}
