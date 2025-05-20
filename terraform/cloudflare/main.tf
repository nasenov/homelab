# Registrar API doesn't support account API tokens
# https://developers.cloudflare.com/fundamentals/api/get-started/account-owned-tokens/#compatibility-matrix
# resource "cloudflare_registrar_domain" "nasenov_dev" {
#   account_id  = var.cloudflare_account_id
#   domain_name = "nasenov.dev"
#   auto_renew  = true
#   locked      = true
#   privacy     = true
# }

resource "cloudflare_zone" "nasenov_dev" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "nasenov.dev"
  type = "full"
}

resource "cloudflare_zone_dnssec" "nasenov_dev" {
  zone_id = cloudflare_zone.nasenov_dev.id
  status  = "active"
}

resource "cloudflare_zone_setting" "ssl" {
  zone_id    = cloudflare_zone.nasenov_dev.id
  setting_id = "ssl"
  value      = "strict"
}

data "cloudflare_account_api_token_permission_groups_list" "permission_groups" {
  account_id = var.cloudflare_account_id
}

resource "cloudflare_account_token" "proxmox" {
  account_id = var.cloudflare_account_id
  name       = "proxmox"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.dns_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      }
    }
  ]
}

resource "cloudflare_account_token" "truenas" {
  account_id = var.cloudflare_account_id
  name       = "truenas"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.dns_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      }
    }
  ]
}

resource "cloudflare_account_token" "cert_manager" {
  account_id = var.cloudflare_account_id
  name       = "cert-manager"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.dns_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      }
    }
  ]
}

resource "cloudflare_account_token" "external_dns" {
  account_id = var.cloudflare_account_id
  name       = "external-dns"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.dns_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      }
    }
  ]
}

resource "cloudflare_r2_bucket" "volsync" {
  account_id    = var.cloudflare_account_id
  name          = "volsync"
  location      = "EEUR"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_account_token" "volsync" {
  account_id = var.cloudflare_account_id
  name       = cloudflare_r2_bucket.volsync.name
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.volsync.jurisdiction}_${cloudflare_r2_bucket.volsync.name}" = "*"
      }
    }
  ]
}

resource "cloudflare_r2_bucket" "postgres" {
  account_id    = var.cloudflare_account_id
  name          = "postgres"
  location      = "EEUR"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_account_token" "postgres" {
  account_id = var.cloudflare_account_id
  name       = cloudflare_r2_bucket.postgres.name
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = {
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.postgres.jurisdiction}_${cloudflare_r2_bucket.postgres.name}" = "*"
      }
    }
  ]
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab" {
  account_id = var.cloudflare_account_id
  name       = "homelab"
  config_src = "cloudflare"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "homelab" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab.id
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

resource "cloudflare_dns_record" "nasenov_dev" {
  zone_id = cloudflare_zone.nasenov_dev.id
  type    = "CNAME"
  name    = "nasenov.dev"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "external_nasenov_dev" {
  zone_id = cloudflare_zone.nasenov_dev.id
  type    = "CNAME"
  name    = "external.nasenov.dev"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.homelab.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
