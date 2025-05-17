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

variable "talos_version" {
  type = string
}

variable "talos_cluster_name" {
  type = string
}

variable "talos_cluster_endpoint" {
  type = string
}
