data "talos_image_factory_extensions_versions" "this" {
  # renovate: datasource=docker depName=ghcr.io/siderolabs/installer
  talos_version = "v1.12.1"

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
  talos_version = data.talos_image_factory_extensions_versions.this.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = "homelab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://k8s.nasenov.dev:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kubernetes_version = "v1.35.0"
  config_patches = [
    file("${path.module}/resources/config.yaml"),
    file("${path.module}/resources/layer2vipconfig.yaml"),
    file("${path.module}/resources/oomconfig.yaml"),
    file("${path.module}/resources/uservolumeconfig.yaml"),
    file("${path.module}/resources/watchdogtimerconfig.yaml"),
    # tuppr requirement
    yamlencode({
      machine = {
        install = {
          # https://github.com/siderolabs/terraform-provider-talos/issues/293
          # image = data.talos_image_factory_urls.this.urls.installer
          image = "factory.talos.dev/nocloud-installer/d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30:v1.12.1"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.controlplane

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = each.key
  endpoint                    = each.value.ipv4_address
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.controlplane.k8s-1.ipv4_address
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane.k8s-1.ipv4_address
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

  cluster_name         = data.talos_machine_configuration.this.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in local.controlplane : v.ipv4_address]
  nodes                = [for k, v in local.controlplane : v.ipv4_address]
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
  endpoints              = [for k, v in local.controlplane : v.ipv4_address]
  control_plane_nodes    = [for k, v in local.controlplane : v.ipv4_address]
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
  version       = "1.18.6"
  wait_for_jobs = true

  values = [
    file("../../kubernetes/apps/kube-system/cilium/app/values.yaml")
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
  version    = "1.45.0"

  values = [
    file("../../kubernetes/apps/kube-system/coredns/app/values.yaml")
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
  endpoints            = [for k, v in local.controlplane : v.ipv4_address]
  control_plane_nodes  = [for k, v in local.controlplane : v.ipv4_address]

  timeouts = {
    read = "5m"
  }
}
