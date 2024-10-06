resource "proxmox_virtual_environment_vm" "k8s_1" {
  name      = "k8s-1"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 2
    units   = 100
  }

  memory {
    dedicated = 2048
    floating  = 2048
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
        address = "192.168.1.21/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_2" {
  name      = "k8s-2"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 2
    units   = 100
  }

  memory {
    dedicated = 2048
    floating  = 2048
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
        address = "192.168.1.22/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_3" {
  name      = "k8s-3"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 2
    units   = 100
  }

  memory {
    dedicated = 2048
    floating  = 2048
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
        address = "192.168.1.23/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_4" {
  name      = "k8s-4"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.24/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_5" {
  name      = "k8s-5"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.25/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_6" {
  name      = "k8s-6"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.26/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_7" {
  name      = "k8s-7"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.27/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_8" {
  name      = "k8s-8"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.28/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_9" {
  name      = "k8s-9"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
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
        address = "192.168.1.29/24"
        gateway = "192.168.1.1"
      }
    }
  }

}

resource "proxmox_virtual_environment_vm" "k8s_10" {
  name      = "k8s-10"
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 1
    units   = 100
  }

  memory {
    dedicated = 1024
    floating  = 1024
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_format  = "raw"
    file_id      = "local:iso/nocloud-amd64.img"
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
        address = "192.168.1.30/24"
        gateway = "192.168.1.1"
      }
    }
  }

}
