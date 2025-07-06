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
      version = "0.79.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
