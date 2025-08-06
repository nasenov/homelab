resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  namespace        = "flux-system"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = "0.27.0"
  create_namespace = true

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "kubernetes_secret_v1" "sops_age" {
  metadata {
    name      = "sops-age"
    namespace = helm_release.flux_operator.namespace
  }

  data = {
    "age.agekey" = file("../../age.agekey")
  }

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "helm_release" "flux_instance" {
  name       = "flux-instance"
  namespace  = kubernetes_secret_v1.sops_age.metadata[0].namespace
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  version    = "0.27.0"

  values = [
    file("../../kubernetes/apps/flux-system/flux-instance/app/values.yaml")
  ]

  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}
