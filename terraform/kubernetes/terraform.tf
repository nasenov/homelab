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
      version = "0.66.3"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}
