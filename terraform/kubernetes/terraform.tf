terraform {
  cloud {
    organization = "nasenov"

    workspaces {
      name = "kubernetes"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }
  }
}
