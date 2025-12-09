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
      version = "0.89.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}
