variable "proxmox_api_url" {
  type = string
}

variable "proxmox_username" {
  type      = string
  sensitive = true
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "ci_user" {
  type = string
}

variable "ci_password" {
  type      = string
  sensitive = true
}

variable "sshkeys" {
  type = list(string)
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_token" {
  type      = string
  sensitive = true
}
