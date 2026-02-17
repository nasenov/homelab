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

data "talos_machine_configuration" "k8s_3" {
  cluster_name     = "homelab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://k8s.nasenov.dev:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kubernetes_version = "v1.35.0"
  config_patches = [
    file("${path.module}/resources/config.yaml"),
    file("${path.module}/resources/k8s-3.yaml"),
    file("${path.module}/resources/layer2vipconfig.yaml"),
    file("${path.module}/resources/oomconfig.yaml"),
    file("${path.module}/resources/uservolumeconfig.yaml"),
    file("${path.module}/resources/watchdogtimerconfig.yaml"),
    # tuppr requirement
    yamlencode({
      machine = {
        install = {
          # https://github.com/siderolabs/terraform-provider-talos/issues/293
          image = "factory.talos.dev/metal-installer/dc8730aa8cc7bfa5ef7e2b3284248f2631135b2faf4ae11aa997a0c1987b0eee:v1.12.1"
          diskSelector = {
            model = "INTEL SSDPEKKF256G7L"
          }
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s_1" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = "k8s-1"
  endpoint                    = "192.168.0.21"
}

resource "talos_machine_configuration_apply" "k8s_2" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = "k8s-2"
  endpoint                    = "192.168.0.22"
}

resource "talos_machine_configuration_apply" "k8s_3" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.k8s_3.machine_configuration
  node                        = "k8s-3"
  endpoint                    = "192.168.0.23"
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.k8s_1,
    talos_machine_configuration_apply.k8s_2,
    talos_machine_configuration_apply.k8s_3
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = "192.168.0.21"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = "192.168.0.21"
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = pathexpand("~/.kube/config")
  file_permission = "0600"
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
}

data "talos_client_configuration" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  cluster_name         = data.talos_machine_configuration.this.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]
  nodes                = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]
}

resource "local_sensitive_file" "talosconfig" {
  filename        = pathexpand("~/.talos/config")
  file_permission = "0600"
  content         = data.talos_client_configuration.this.talos_config
}

data "talos_cluster_health" "talos" {
  depends_on = [
    talos_cluster_kubeconfig.this
  ]

  client_configuration   = talos_machine_secrets.this.client_configuration
  endpoints              = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]
  control_plane_nodes    = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]
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
  repository    = "oci://quay.io/cilium/charts"
  chart         = "cilium"
  version       = "1.19.1"
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
  endpoints            = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]
  control_plane_nodes  = ["192.168.0.21", "192.168.0.22", "192.168.0.23"]

  timeouts = {
    read = "5m"
  }
}
