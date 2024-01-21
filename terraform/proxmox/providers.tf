provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  ssh {
    agent = true
    node {
      name    = "debian"
      address = "192.168.1.208"
    }
  }
}
