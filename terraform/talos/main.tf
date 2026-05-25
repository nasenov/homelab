data "talos_image_factory_extensions_versions" "this" {
  # renovate: datasource=custom.talos-factory depName=siderolabs/talos
  talos_version = "v1.13.2"

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
  kubernetes_version = "v1.36.1"

  config_patches = concat(
    [for file_name in fileset(path.module, "resources/*.yaml") : file("${path.module}/${file_name}")],
    # tuppr requirement
    [
      yamlencode({
        machine = {
          install = {
            image = data.talos_image_factory_urls.this.urls.installer
          }
        }
      })
    ]
  )
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.controlplanes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = each.key
  endpoint                    = each.value.ipv4_address

  config_patches = [
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      hostname   = each.key
      auto       = "off"
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = talos_machine_configuration_apply.this["k8s-1"].endpoint
}

data "talos_client_configuration" "this" {
  cluster_name         = data.talos_machine_configuration.this.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.endpoints
  nodes                = local.endpoints
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = talos_machine_bootstrap.this.node
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_cluster_kubeconfig.this
  ]

  client_configuration   = talos_machine_secrets.this.client_configuration
  endpoints              = local.endpoints
  control_plane_nodes    = local.endpoints
  skip_kubernetes_checks = true

  timeouts = {
    read = "5m"
  }
}
