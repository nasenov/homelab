provider "kubernetes" {
  config_path = "../../kubeconfig"
}

provider "helm" {
  kubernetes = {
    config_path = "../../kubeconfig"
  }
}
