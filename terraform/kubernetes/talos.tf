resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "homelab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://192.168.1.21:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "homelab"
  machine_type     = "worker"
  cluster_endpoint = "https://192.168.1.21:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = "homelab"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = ["192.168.1.21", "192.168.1.22", "192.168.1.23"]
}

resource "talos_machine_configuration_apply" "k8s-1" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_1
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = "192.168.1.21"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-2" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_2
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = "192.168.1.22"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-3" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_3
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = "192.168.1.23"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-4" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_4
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.24"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-5" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_5
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.25"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-6" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_6
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.26"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.k8s-1,
    talos_machine_configuration_apply.k8s-2,
    talos_machine_configuration_apply.k8s-3,
    talos_machine_configuration_apply.k8s-4,
    talos_machine_configuration_apply.k8s-5,
    talos_machine_configuration_apply.k8s-6
  ]
  node                 = "192.168.1.21"
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = "192.168.1.21"
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = pathexpand("~/.kube/config")
}

# resource "local_file" "talosconfig" {
#   content  = data.talos_client_configuration.this.talos_config
#   filename = "talosconfig"
# }
