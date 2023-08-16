provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  # pm_api_token_id     = var.proxmox_api_token_id
  # pm_api_token_secret = var.proxmox_api_token_secret

  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password

  pm_tls_insecure = true
}
