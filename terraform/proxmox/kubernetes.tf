resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  node_name    = "debian"
  datastore_id = "local"

  source_file {
    path     = "https://cloud-images.ubuntu.com/releases/23.10/release-20231011/ubuntu-23.10-server-cloudimg-amd64.img"
    checksum = "f6529be56da3429a56e4f5ef202bf4958201bc63f8541e478caa6e8eb712e635"
  }
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  node_name    = "debian"
  datastore_id = "local"
  content_type = "snippets"

  source_raw {
    file_name = "vendorconfig.yaml"
    data = <<EOF
#cloud-config
runcmd:
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF
  }
}

resource "proxmox_virtual_environment_vm" "k3s_1" {
  name      = "k3s-1"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
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
        address = "192.168.1.121/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}

resource "proxmox_virtual_environment_vm" "k3s_2" {
  name      = "k3s-2"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
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
        address = "192.168.1.122/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}

resource "proxmox_virtual_environment_vm" "k3s_3" {
  name      = "k3s-3"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
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
        address = "192.168.1.123/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}


resource "proxmox_virtual_environment_vm" "k3s_4" {
  name      = "k3s-4"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 16384
    floating  = 16384
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
  }

  disk {
    datastore_id = "longhorn-1"
    interface    = "scsi1"
    file_format = "raw"
    size         = 953
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:00:02"
    pcie   = true
    rombar = false
  }

  usb {
    host = "10c4:ea60"
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
        address = "192.168.1.124/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}

resource "proxmox_virtual_environment_vm" "k3s_5" {
  name      = "k3s-5"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 16384
    floating  = 16384
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
  }

  disk {
    datastore_id = "longhorn-2"
    interface    = "scsi1"
    file_format = "raw"
    size         = 953
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
        address = "192.168.1.125/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}

resource "proxmox_virtual_environment_vm" "k3s_6" {
  name      = "k3s-6"
  node_name = "debian"

  machine = "q35"
  started = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 16384
    floating  = 16384
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 64
  }

  disk {
    datastore_id = "longhorn-3"
    interface    = "scsi1"
    file_format = "raw"
    size         = 953
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
        address = "192.168.1.126/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  template = true
  vm_id = 9000

  name      = "ubuntu-mantic"
  node_name = "debian"

  machine = "q35"
  started = false

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = 4
    units   = 100
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 4
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
        address = "dhcp"
      }
    }

    user_account {
      username = var.ci_user
      password = var.ci_password
      keys     = var.sshkeys
    }

    vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
  }

}
