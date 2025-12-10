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
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      })
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
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${cloudflare_zone.nasenov_dev.id}" = "*"
      })
    }
  ]
}

resource "cloudflare_account_token" "traefik" {
  account_id = var.cloudflare_account_id
  name       = "traefik"
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

resource "cloudflare_account_token" "cert_manager" {
  account_id = var.cloudflare_account_id
  name       = "cert-manager"
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

resource "cloudflare_account_token" "external_dns" {
  account_id = var.cloudflare_account_id
  name       = "external-dns"
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
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.volsync.jurisdiction}_${cloudflare_r2_bucket.volsync.name}" = "*"
      })
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
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.postgres.jurisdiction}_${cloudflare_r2_bucket.postgres.name}" = "*"
      })
    }
  ]
}

resource "cloudflare_r2_bucket" "obsidian" {
  account_id    = var.cloudflare_account_id
  name          = "obsidian"
  location      = "EEUR"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_account_token" "obsidian" {
  account_id = var.cloudflare_account_id
  name       = cloudflare_r2_bucket.obsidian.name
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_${cloudflare_r2_bucket.obsidian.jurisdiction}_${cloudflare_r2_bucket.obsidian.name}" = "*"
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

resource "cloudflare_notification_policy" "r2_storage" {
  account_id = var.cloudflare_account_id
  name       = "R2 Storage"
  alert_type = "billing_usage_alert"
  mechanisms = {
    email = [{
      "id" : var.email
    }]
  }
  filters = {
    product = ["r2_storage"]
    limit   = ["7516192768"] # 7 GB
  }
}

resource "cloudflare_notification_policy" "r2_class_a_operations" {
  account_id = var.cloudflare_account_id
  name       = "R2 Class A"
  alert_type = "billing_usage_alert"
  mechanisms = {
    email = [{
      "id" : var.email
    }]
  }
  filters = {
    product = ["r2_class_a_operations"]
    limit   = ["700000"]
  }
}

resource "cloudflare_notification_policy" "r2_class_b_operations" {
  account_id = var.cloudflare_account_id
  name       = "R2 Class B"
  alert_type = "billing_usage_alert"
  mechanisms = {
    email = [{
      "id" : var.email
    }]
  }
  filters = {
    product = ["r2_class_b_operations"]
    limit   = ["7000000"]
  }
}

resource "cloudflare_notification_policy" "cloudflare_tunnel_health" {
  account_id = var.cloudflare_account_id
  name       = "Cloudflare Tunnel"
  alert_type = "tunnel_health_event"
  mechanisms = {
    email = [{
      "id" : var.email
    }]
  }
  filters = {
    "new_status" : [
      "TUNNEL_STATUS_TYPE_DEGRADED",
      "TUNNEL_STATUS_TYPE_DOWN"
    ]
  }
}
