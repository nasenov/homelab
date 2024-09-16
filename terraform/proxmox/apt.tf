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
