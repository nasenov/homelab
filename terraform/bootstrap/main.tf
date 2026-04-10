data "helm_template" "external_secrets" {
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "oci://ghcr.io/external-secrets/charts"
  chart      = "external-secrets"
  version    = "2.2.0"

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
    namespace = helm_release.external_secrets.namespace
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
