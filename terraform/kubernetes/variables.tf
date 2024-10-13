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

variable "talos_controlplane_config_patches" {

}

variable "talos_worker_config_patches" {
  
}
