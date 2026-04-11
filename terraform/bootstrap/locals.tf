locals {
  external_secrets = {
    name       = "external-secrets"
    namespace  = "external-secrets"
    repository = "oci://ghcr.io/external-secrets/charts"
    chart      = "external-secrets"

    # renovate: datasource=docker depName=ghcr.io/external-secrets/charts/external-secrets
    version = "2.2.0"
  }
}
