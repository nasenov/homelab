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
      version = "2.37.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0"
    }
  }
}
