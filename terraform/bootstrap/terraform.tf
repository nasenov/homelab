terraform {
  cloud {
    organization = "nasenov"

    workspaces {
      name = "bootstrap"
    }
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}
