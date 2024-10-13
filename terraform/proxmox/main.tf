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
  url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Dragonfish/24.04.2.2/TrueNAS-SCALE-24.04.2.2.iso"
  checksum_algorithm = "sha256"
  checksum           = "1ba1805a7a579a7d8313764b1e11b4b10d00e861def45ba2880f3049a6b0e354"
}

resource "proxmox_virtual_environment_download_file" "talos" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "iso"
  file_name    = "nocloud-amd64.img"
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.0/nocloud-amd64.raw"
}
