terraform {
  cloud {
    organization = "nasenov"

    workspaces {
      name = "proxmox-bpg"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.87.0"
    }
  }
}
