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
        "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
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
        "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
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
        "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
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
        "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
      }
    }
  ]
}

# https://github.com/cloudflare/terraform-provider-cloudflare/issues/5373
# resource "cloudflare_r2_bucket" "volsync" {
#   account_id    = var.cloudflare_account_id
#   name          = "volsync"
#   location      = "eeur"
#   storage_class = "Standard"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "cloudflare_account_token" "volsync" {
  account_id = var.cloudflare_account_id
  name       = "volsync"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = {
        # TODO: use bucket name and jurisdiction from cloudflare_r2_bucket
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_volsync" = "*"
      }
    }
  ]
}

# https://github.com/cloudflare/terraform-provider-cloudflare/issues/5373
# resource "cloudflare_r2_bucket" "postgres" {
#   account_id    = var.cloudflare_account_id
#   name          = "postgres"
#   location      = "eeur"
#   storage_class = "Standard"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "cloudflare_account_token" "postgres" {
  account_id = var.cloudflare_account_id
  name       = "postgres"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        { id = local.r2_bucket_write_permission_group.id }
      ]
      resources = {
        # TODO: use bucket name and jurisdiction from cloudflare_r2_bucket
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_postgres" = "*"
      }
    }
  ]
}

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
