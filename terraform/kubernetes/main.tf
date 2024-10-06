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
      version = "0.66.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
}
