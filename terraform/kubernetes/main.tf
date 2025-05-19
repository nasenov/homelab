resource "proxmox_virtual_environment_vm" "k8s" {
  for_each = merge(local.controlplane_virtual_machines, local.worker_virtual_machines)

  name      = each.key
  node_name = "pve"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = true

  cpu {
    type    = "x86-64-v2-AES"
    sockets = 1
    cores   = each.value.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  network_device {

  }

  disk {
    datastore_id = "fast"
    file_id      = "local:iso/nocloud-amd64.img"
    file_format  = "raw"
    interface    = "scsi0"
    iothread     = true
    size         = 100
    cache        = "writeback"
  }

  dynamic "hostpci" {
    for_each = each.value.hostpci

    content {
      device = "hostpci0"
      id     = hostpci.value
      pcie   = true
      rombar = true
    }
  }

  dynamic "hostpci" {
    for_each = each.value.gpu

    content {
      device = "hostpci0"
      id     = hostpci.value
      pcie   = true
      rombar = false
    }
  }

  dynamic "usb" {
    for_each = each.value.usb

    content {
      host = usb.value
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "local-lvm"

    dns {
      servers = ["192.168.0.53"]
    }

    ip_config {
      ipv4 {
        address = "${each.value.ipv4_address}/24"
        gateway = "192.168.0.1"
      }
    }
  }
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "qemu-guest-agent",
      "i915"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
    }
    }
  )
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = local.kubernetes_version
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = local.controlplane_virtual_machines

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
  endpoint                    = each.value.ipv4_address
  config_patches = [
    local.talos_install_image_config_patch,
    local.talos_vip_config_patch,
    local.talos_sysctls_config_patch,
    local.talos_kernel_modules_config_patch,
    local.talos_kubelet_config_patch,
    local.talos_containerd_config_patch,
    local.talos_cluster_network_config_patch,
    local.talos_discovery_service_patch,
    local.talos_cluster_controller_manager_config_patch,
    local.talos_cluster_scheduler_config_patch,
    local.talos_cluster_etcd_config_patch,
    local.talos_cluster_apiserver_config_patch,
    local.talos_kubernetes_talos_api_access_config_patch
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
  ]
  node                 = local.controlplane_virtual_machines.k8s-1.ipv4_address
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "worker"
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = local.kubernetes_version
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_bootstrap.this
  ]

  for_each = local.worker_virtual_machines

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  endpoint                    = each.value.ipv4_address
  config_patches = [
    local.talos_install_image_config_patch,
    local.talos_sysctls_config_patch,
    local.talos_kernel_modules_config_patch,
    local.talos_kubelet_config_patch,
    local.talos_containerd_config_patch,
    local.talos_cluster_network_config_patch,
    local.talos_discovery_service_patch
  ]
}

# https://github.com/siderolabs/terraform-provider-talos/issues/206
resource "time_sleep" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker,
    talos_machine_bootstrap.this
  ]

  create_duration = "5m"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_virtual_machines.k8s-1.ipv4_address
}

data "talos_client_configuration" "this" {
  depends_on = [
    time_sleep.this
  ]

  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
  nodes                = [for k, v in merge(local.controlplane_virtual_machines, local.worker_virtual_machines) : v.ipv4_address]
}
