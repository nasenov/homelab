terraform {
  cloud {
    organization = "nasenov"

    workspaces {
      name = "bootstrap"
    }
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}
