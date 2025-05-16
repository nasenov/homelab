resource "proxmox_virtual_environment_apt_standard_repository" "no_subscription" {
  node   = "pve"
  handle = "no-subscription"
}

resource "proxmox_virtual_environment_apt_standard_repository" "enterprise" {
  node   = "pve"
  handle = "enterprise"
}

resource "proxmox_virtual_environment_apt_repository" "enterprise" {
  enabled   = false
  file_path = proxmox_virtual_environment_apt_standard_repository.enterprise.file_path
  index     = proxmox_virtual_environment_apt_standard_repository.enterprise.index
  node      = proxmox_virtual_environment_apt_standard_repository.enterprise.node
}

resource "proxmox_virtual_environment_apt_standard_repository" "ceph_quincy_enterprise" {
  node   = "pve"
  handle = "ceph-quincy-enterprise"
}

resource "proxmox_virtual_environment_apt_repository" "ceph_quincy_enterprise" {
  enabled   = false
  file_path = proxmox_virtual_environment_apt_standard_repository.ceph_quincy_enterprise.file_path
  index     = proxmox_virtual_environment_apt_standard_repository.ceph_quincy_enterprise.index
  node      = proxmox_virtual_environment_apt_standard_repository.ceph_quincy_enterprise.node
}

resource "proxmox_virtual_environment_acme_account" "letsencrypt" {
  name      = "letsencrypt"
  contact   = "asenov.nikolay98@gmail.com"
  directory = "https://acme-v02.api.letsencrypt.org/directory"
  tos       = "https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf"
}

resource "proxmox_virtual_environment_acme_dns_plugin" "cloudflare" {
  plugin = "cloudflare"
  api    = "cf"
  data = {
    CF_Account_ID = var.cloudflare_account_id
    CF_Token      = var.cloudflare_token
  }
}

resource "proxmox_virtual_environment_download_file" "truenas" {
  node_name          = "pve"
  datastore_id       = "local"
  content_type       = "iso"
  url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.0/TrueNAS-SCALE-25.04.0.iso"
  checksum_algorithm = "sha256"
  checksum           = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
}

resource "proxmox_virtual_environment_download_file" "talos" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "iso"
  file_name    = "nocloud-amd64.img"
  # renovate: datasource=docker depName=ghcr.io/siderolabs/installer
  url = "https://factory.talos.dev/image/d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30/v1.10.2/nocloud-amd64.raw"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  node_name          = "pve"
  datastore_id       = "local"
  content_type       = "iso"
  file_name          = "ubuntu-24.04-server-cloudimg-amd64.img"
  url                = "https://cloud-images.ubuntu.com/releases/noble/release-20250403/ubuntu-24.04-server-cloudimg-amd64.img"
  checksum_algorithm = "sha256"
  checksum           = "071fceadf1ea57a388ff7a1ccb4127155d691a511f6a207b4c11b120563855e2"
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "snippets"

  source_raw {
    file_name = "vendorconfig.yaml"
    data      = <<EOF
#cloud-config
runcmd:
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  template = true
  vm_id    = 9000

  name      = "ubuntu-noble-numbat"
  node_name = "pve"

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
    file_id      = "local:iso/ubuntu-24.04-server-cloudimg-amd64.img"
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

resource "proxmox_virtual_environment_vm" "dns" {
  name      = "dns"
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
    file_id      = "local:iso/ubuntu-24.04-server-cloudimg-amd64.img"
    interface    = "scsi0"
    iothread     = true
    size         = 32
    cache        = "writeback"
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
        address = "192.168.0.53/24"
        gateway = "192.168.0.1"
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
