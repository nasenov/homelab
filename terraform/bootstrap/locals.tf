locals {
  crds = {
    external_secrets = {
      repository = "oci://ghcr.io/external-secrets/charts"
      chart      = "external-secrets"

      # renovate: datasource=docker depName=ghcr.io/external-secrets/charts/external-secrets
      version = "2.3.0"
    }

    envoy_gateway = {
      repository = "oci://mirror.gcr.io/envoyproxy"
      chart      = "gateway-helm"

      # renovate: datasource=docker depName=mirror.gcr.io/envoyproxy/gateway-helm
      version = "v1.7.1"
    }

    grafana_operator = {
      repository = "oci://ghcr.io/grafana/helm-charts"
      chart      = "grafana-operator"

      # renovate: datasource=docker depName=ghcr.io/grafana/helm-charts/grafana-operator
      version = "5.22.2"
    }

    kube_prometheus_stack = {
      repository = "oci://ghcr.io/prometheus-community/charts"
      chart      = "kube-prometheus-stack"

      # renovate: datasource=docker depName=ghcr.io/prometheus-community/charts/kube-prometheus-stack
      version = "83.4.0"
    }
  }
}
