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
  nodes = [
    "192.168.1.21",
    "192.168.1.22",
    "192.168.1.23",
    "192.168.1.24",
    "192.168.1.25",
    "192.168.1.26",
    "192.168.1.27",
    "192.168.1.28",
    "192.168.1.29",
    "192.168.1.30",
  ]
  endpoints = ["192.168.1.21"]
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
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-7" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_7
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.27"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-8" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_8
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.28"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-9" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_9
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.29"
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s-10" {
  depends_on = [
    proxmox_virtual_environment_vm.k8s_10
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = "192.168.1.30"
  config_patches = [
    yamlencode({
      machine = {
        install = {
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
    talos_machine_configuration_apply.k8s-6,
    talos_machine_configuration_apply.k8s-7,
    talos_machine_configuration_apply.k8s-8,
    talos_machine_configuration_apply.k8s-9,
    talos_machine_configuration_apply.k8s-10
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

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")
}
