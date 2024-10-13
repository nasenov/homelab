locals {
  talos_install_image_config_patch = yamlencode({
    machine = {
      install = {
        image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
      }
    }
  })

  talos_vip_config_patch = yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            interface = "eth0"
            vip = {
              ip = "192.168.1.20"
            }
          }
        ]
      }
    }
  })
}

locals {
  controlplane_virtual_machines = {
    k8s_1 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-1"].name
      endpoint = "192.168.1.21"
    }
    k8s_2 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-2"].name
      endpoint = "192.168.1.22"
    }
    k8s_3 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-3"].name
      endpoint = "192.168.1.23"
    }
  }

  worker_virtual_machines = {
    k8s_4 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-4"].name
      endpoint = "192.168.1.24"
    }
    k8s_5 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-5"].name
      endpoint = "192.168.1.25"
    }
    k8s_6 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-6"].name
      endpoint = "192.168.1.26"
    }
    k8s_7 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-7"].name
      endpoint = "192.168.1.27"
    }
    k8s_8 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-8"].name
      endpoint = "192.168.1.28"
    }
    k8s_9 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-9"].name
      endpoint = "192.168.1.29"
    }
    k8s_10 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-10"].name
      endpoint = "192.168.1.30"
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "homelab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://192.168.1.20:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = local.controlplane_virtual_machines

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  config_patches = [
    local.talos_install_image_config_patch,
    local.talos_vip_config_patch
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "homelab"
  machine_type     = "worker"
  cluster_endpoint = "https://192.168.1.20:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = local.worker_virtual_machines

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  config_patches              = [local.talos_install_image_config_patch]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
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

resource "local_sensitive_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = pathexpand("~/.kube/config")
}

data "talos_client_configuration" "this" {
  cluster_name         = "homelab"
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints = [
    "192.168.1.21",
    "192.168.1.22",
    "192.168.1.23"
  ]
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
    "192.168.1.30"
  ]
}

resource "local_sensitive_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")
}
