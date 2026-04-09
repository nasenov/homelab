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

resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = cloudflare_zone.nasenov_dev.id
  setting_id = "always_use_https"
  value      = "on"
}

data "cloudflare_account_api_token_permission_groups_list" "permission_groups" {
  account_id = var.cloudflare_account_id
}

resource "cloudflare_account_token" "dns_write" {
  for_each = local.dns_write_account_tokens

  account_id = var.cloudflare_account_id
  name       = each.key
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.dns_write_permission_group.id }
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      })
    }
  ]
}

resource "cloudflare_r2_bucket" "this" {
  for_each = local.r2_buckets

  account_id    = var.cloudflare_account_id
  name          = each.key
  location      = "EEUR"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_account_token" "r2_bucket_write" {
  for_each = local.r2_buckets

  account_id = var.cloudflare_account_id
  name       = cloudflare_r2_bucket.this[each.key].name
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.this[each.key].jurisdiction}_${cloudflare_r2_bucket.this[each.key].name}" = "*"
      })
    }
  ]
}

resource "cloudflare_account_token" "rclone" {
  account_id = var.cloudflare_account_id
  name       = "rclone"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = jsonencode({
        "com.cloudflare.api.account.${var.cloudflare_account_id}" : "*"
      })
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
    origin_request = {
      http2_origin = true
    }

    ingress = [
      {
        hostname = "nasenov.dev"
        origin_request = {
          origin_server_name = "nasenov.dev"
        }
        service = "https://envoy-external.networking.svc.cluster.local"
      },
      {
        hostname = "*.nasenov.dev"
        origin_request = {
          origin_server_name = "*.nasenov.dev"
        }
        service = "https://envoy-external.networking.svc.cluster.local"
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

resource "cloudflare_notification_policy" "this" {
  for_each = local.cloudflare_notifications

  account_id = var.cloudflare_account_id
  name       = each.value.name
  alert_type = each.value.alert_type
  filters    = each.value.filters

  mechanisms = {
    email = [{
      "id" : var.email
    }]
  }
}
