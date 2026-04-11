data "helm_template" "this" {
  for_each = local.crds

  name         = each.value.chart
  repository   = each.value.repository
  chart        = each.value.chart
  version      = each.value.version
  include_crds = true

  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kube_version = "v1.35.3"
}

resource "kubernetes_manifest" "this" {
  for_each = {
    for manifest in flatten([for ht in data.helm_template.this : provider::kubernetes::manifest_decode_multi(ht.manifest)]) :
    manifest.metadata.name => {
      "apiVersion" = manifest.apiVersion
      "kind"       = manifest.kind
      "metadata"   = manifest.metadata
      "spec"       = manifest.spec
    }
    if manifest.apiVersion == "apiextensions.k8s.io/v1" && manifest.kind == "CustomResourceDefinition"
  }

  manifest = each.value

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "kubernetes_secret_v1" "bitwarden_access_token" {
  metadata {
    name      = "bitwarden-access-token"
    namespace = local.crds.external_secrets.chart
  }

  data = {
    "token" = var.bitwarden_access_token
  }

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "helm_release" "flux_operator" {
  depends_on = [
    kubernetes_secret_v1.bitwarden_access_token
  ]

  name             = "flux-operator"
  namespace        = "flux-system"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = "0.46.0"
  create_namespace = true

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "helm_release" "flux_instance" {
  name       = "flux-instance"
  namespace  = helm_release.flux_operator.namespace
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  version    = "0.46.0"

  values = [
    file("../../kubernetes/apps/flux-system/flux-instance/app/values.yaml")
  ]

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}
