provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  ssh {
    agent = true
    node {
      name    = "pve"
      address = "192.168.0.10"
    }
  }
}

provider "talos" {}
