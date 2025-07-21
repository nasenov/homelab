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
      version = "2.38.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
