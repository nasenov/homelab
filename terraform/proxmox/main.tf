terraform {
  cloud {
    organization = "nasenov"

    workspaces {
      name = "proxmox"
    }
  }

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
