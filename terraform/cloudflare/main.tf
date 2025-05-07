resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab" {
  account_id = var.cloudflare_account_id
  name       = "homelab"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab.id
  source     = "cloudflare"
  config = {
    # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5508
    # origin_request = {
    #   http2_origin       = true
    #   origin_server_name = "external.nasenov.dev"
    # }

    ingress = [
      {
        hostname = "nasenov.dev"
        service  = "https://cilium-gateway-external.kube-system.svc.cluster.local"
        origin_request = {
          http2_origin       = true
          origin_server_name = "external.nasenov.dev"
        }
      },
      {
        hostname = "*.nasenov.dev"
        service  = "https://cilium-gateway-external.kube-system.svc.cluster.local"
        origin_request = {
          http2_origin       = true
          origin_server_name = "external.nasenov.dev"
        }
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "homelab" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab.id
}

resource "cloudflare_dns_record" "external" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "external.nasenov.dev"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_r2_bucket" "volsync" {
  account_id    = var.cloudflare_account_id
  name          = "volsync"
  location      = "eeur"
  storage_class = "Standard"
}

resource "cloudflare_r2_bucket" "postgres" {
  account_id    = var.cloudflare_account_id
  name          = "postgres"
  location      = "eeur"
  storage_class = "Standard"
}
