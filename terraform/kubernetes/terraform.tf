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
      version = "0.78.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}
