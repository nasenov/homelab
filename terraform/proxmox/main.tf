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

resource "proxmox_virtual_environment_apt_standard_repository" "ceph_squid_enterprise" {
  node   = "pve"
  handle = "ceph-squid-enterprise"
}

resource "proxmox_virtual_environment_apt_repository" "ceph_squid_enterprise" {
  enabled   = false
  file_path = proxmox_virtual_environment_apt_standard_repository.ceph_squid_enterprise.file_path
  index     = proxmox_virtual_environment_apt_standard_repository.ceph_squid_enterprise.index
  node      = proxmox_virtual_environment_apt_standard_repository.ceph_squid_enterprise.node
}

resource "proxmox_virtual_environment_acme_account" "letsencrypt" {
  name      = "letsencrypt"
  contact   = "10465782+nasenov@users.noreply.github.com"
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

resource "proxmox_virtual_environment_hardware_mapping_pci" "hba" {
  name = "hba"
  map = [{
    node         = "pve"
    path         = "0000:05:00.0"
    id           = "1000:0087"
    subsystem_id = "1000:3020"
    iommu_group  = 15
  }]
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "gpu" {
  name = "gpu"
  map = [{
    node         = "pve"
    path         = "0000:00:02.0"
    id           = "8086:a780"
    subsystem_id = "1458:d000"
    iommu_group  = 0
  }]
}

resource "proxmox_virtual_environment_hardware_mapping_usb" "zigbee" {
  name = "zigbee"
  map = [{
    node = "pve"
    id   = "10c4:ea60"
  }]
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
  url          = "https://factory.talos.dev/image/d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30/v1.12.1/nocloud-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = local.talos_virtual_machines

  name      = each.key
  node_name = "pve"

  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  started         = true
  stop_on_destroy = true

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
    file_id      = "local:iso/${proxmox_virtual_environment_download_file.talos.file_name}"
    file_format  = "raw"
    interface    = "scsi0"
    iothread     = true
    size         = 238
    cache        = "writeback"
  }

  dynamic "hostpci" {
    for_each = each.value.hostpci

    content {
      device  = "hostpci0"
      mapping = hostpci.value
      pcie    = true
      rombar  = true
    }
  }

  dynamic "hostpci" {
    for_each = each.value.gpu

    content {
      device  = "hostpci1"
      mapping = hostpci.value
      pcie    = true
      rombar  = false
    }
  }

  dynamic "usb" {
    for_each = each.value.usb

    content {
      mapping = usb.value
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "local-lvm"

    dns {
      servers = ["192.168.0.53"]
    }

    ip_config {
      ipv4 {
        address = "${each.value.ipv4_address}/24"
        gateway = "192.168.0.1"
      }
    }
  }
}
