resource "proxmox_virtual_environment_vm" "this" {
  for_each = local.controlplane_virtual_machines

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
    size         = 128
    cache        = "writeback"
  }

  disk {
    datastore_id = "fast"
    file_format  = "raw"
    interface    = "scsi1"
    iothread     = true
    size         = 64
    cache        = "writeback"
  }

  dynamic "hostpci" {
    for_each = each.value.hostpci

    content {
      device  = "hostpci0"
      mapping = hostpci.value
      pcie    = true
      rombar  = true
    }
  }

  dynamic "hostpci" {
    for_each = each.value.gpu

    content {
      device  = "hostpci1"
      mapping = hostpci.value
      pcie    = true
      rombar  = false
    }
  }

  dynamic "usb" {
    for_each = each.value.usb

    content {
      mapping = usb.value
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
  talos_version = local.talos_version
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
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}

resource "talos_machine_secrets" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.this
  ]
}

data "talos_machine_configuration" "this" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = local.kubernetes_version
  config_patches = [
    local.talos_install_image_config_patch, # TNU requirement
    file("${path.module}/resources/config.yaml"),
    file("${path.module}/resources/uservolumeconfig.yaml"),
    file("${path.module}/resources/watchdogtimerconfig.yaml")
  ]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.controlplane_virtual_machines

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = each.key
  endpoint                    = each.value.ipv4_address
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.controlplane_virtual_machines.k8s-1.ipv4_address
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_virtual_machines.k8s-1.ipv4_address
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = pathexpand("~/.kube/config")
  file_permission = "0600"
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
}

data "talos_client_configuration" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]

  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
  nodes                = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
}

resource "local_sensitive_file" "talosconfig" {
  filename        = pathexpand("~/.talos/config")
  file_permission = "0600"
  content         = data.talos_client_configuration.this.talos_config
}

data "talos_cluster_health" "talos" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_cluster_kubeconfig.this
  ]

  client_configuration   = talos_machine_secrets.this.client_configuration
  endpoints              = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
  control_plane_nodes    = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
  skip_kubernetes_checks = true
  timeouts = {
    read = "5m"
  }
}

resource "helm_release" "cilium" {
  depends_on = [
    data.talos_cluster_health.talos
  ]

  name          = "cilium"
  namespace     = "kube-system"
  repository    = "https://helm.cilium.io"
  chart         = "cilium"
  version       = "1.18.1"
  wait_for_jobs = true

  values = [
    file("../../kubernetes/apps/kube-system/cilium/app/helm-values.yaml")
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "helm_release" "coredns" {
  depends_on = [
    helm_release.cilium
  ]

  name       = "coredns"
  namespace  = "kube-system"
  repository = "oci://ghcr.io/coredns/charts"
  chart      = "coredns"
  version    = "1.43.3"

  values = [
    file("../../kubernetes/apps/kube-system/coredns/app/helm-values.yaml")
  ]

  lifecycle {
    ignore_changes = all
  }
}

data "talos_cluster_health" "kubernetes" {
  depends_on = [
    helm_release.coredns
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]
  control_plane_nodes  = [for k, v in local.controlplane_virtual_machines : v.ipv4_address]

  timeouts = {
    read = "5m"
  }
}
