data "helm_template" "external_secrets" {
  name       = local.external_secrets.name
  namespace  = local.external_secrets.namespace
  repository = local.external_secrets.repository
  chart      = local.external_secrets.chart
  version    = local.external_secrets.version

  show_only = [
    "templates/crds/*.yaml"
  ]
}

resource "kubernetes_manifest" "external_secrets_crds" {
  for_each = {
    for manifest in data.helm_template.external_secrets.manifests : yamldecode(manifest).metadata.name => yamldecode(manifest)
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
    namespace = local.external_secrets.namespace
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
