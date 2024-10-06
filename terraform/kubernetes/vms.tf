resource "proxmox_virtual_environment_download_file" "talos" {
  node_name               = "pve"
  datastore_id            = "local"
  content_type            = "iso"
  file_name               = "nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.0/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "k8s_1" {
  name      = "k8s-1"
  node_name = "pve"

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

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

  machine = "q35"
  started = true

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
    file_id      = proxmox_virtual_environment_download_file.talos.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 10
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "fast"

    ip_config {
      ipv4 {
        address = "192.168.1.30/24"
        gateway = "192.168.1.1"
      }
    }
  }

}
