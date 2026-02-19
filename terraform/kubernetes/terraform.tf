terraform {
  backend "s3" {
    region                      = "auto"
    bucket                      = "tfstate"
    key                         = "kubernetes/terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}
