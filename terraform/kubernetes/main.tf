data "talos_image_factory_extensions_versions" "this" {
  # renovate: datasource=docker depName=ghcr.io/siderolabs/installer
  talos_version = "v1.12.4"

  filters = {
    names = [
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
  platform      = "metal"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = "homelab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://k8s.nasenov.dev:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kubernetes_version = "v1.35.2"
  config_patches = [
    file("${path.module}/resources/config.yaml"),
    file("${path.module}/resources/ethernetconfig.yaml"),
    file("${path.module}/resources/layer2vipconfig.yaml"),
    file("${path.module}/resources/resolverconfig.yaml"),
    file("${path.module}/resources/timesyncconfig.yaml"),
    file("${path.module}/resources/uservolumeconfig.yaml"),
    file("${path.module}/resources/watchdogtimerconfig.yaml"),
    # tuppr requirement
    yamlencode({
      machine = {
        install = {
          image = data.talos_image_factory_urls.this.urls.installer
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s_1" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = "k8s-1"
  endpoint                    = "192.168.0.121"
  config_patches = [
    file("${path.module}/resources/k8s-1.yaml"),
    yamlencode({
      machine = {
        install = {
          diskSelector = {
            model = "SAMSUNG MZVLB256HAHQ-000L7"
          }
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s_2" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = "k8s-2"
  endpoint                    = "192.168.0.122"
  config_patches = [
    file("${path.module}/resources/k8s-2.yaml"),
    yamlencode({
      machine = {
        install = {
          diskSelector = {
            model = "WDC PC SN720 SDAPNTW-256G-1006"
          }
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "k8s_3" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = "k8s-3"
  endpoint                    = "192.168.0.123"
  config_patches = [
    file("${path.module}/resources/k8s-3.yaml"),
    yamlencode({
      machine = {
        install = {
          diskSelector = {
            model = "INTEL SSDPEKKF256G7L"
          }
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.k8s_1,
    talos_machine_configuration_apply.k8s_2,
    talos_machine_configuration_apply.k8s_3
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = talos_machine_configuration_apply.k8s_1.endpoint
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = talos_machine_configuration_apply.k8s_1.endpoint
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

  endpoints = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]

  nodes = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]
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

  client_configuration = talos_machine_secrets.this.client_configuration

  endpoints = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]

  control_plane_nodes = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]

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
  version    = "1.45.2"

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

  endpoints = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]

  control_plane_nodes = [
    talos_machine_configuration_apply.k8s_1.endpoint,
    talos_machine_configuration_apply.k8s_2.endpoint,
    talos_machine_configuration_apply.k8s_3.endpoint
  ]

  timeouts = {
    read = "5m"
  }
}
