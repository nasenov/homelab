locals {
  dns_write_account_tokens   = toset(["cert-manager", "external-dns", "traefik", "truenas"])
  dns_write_permission_group = one([for permission_group in data.cloudflare_account_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "DNS Write"])
}

locals {
  r2_buckets                       = toset(["obsidian", "postgres", "volsync"])
  r2_bucket_write_permission_group = one([for permission_group in data.cloudflare_account_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "Workers R2 Storage Bucket Item Write"])
}

locals {
  cloudflare_notifications = {
    r2_storage = {
      name       = "R2 Storage"
      alert_type = "billing_usage_alert"

      filters = {
        product = ["r2_storage"]
        limit   = ["7516192768"] # 7 GB
      }
    }
    r2_class_a_operations = {
      name       = "R2 Class A"
      alert_type = "billing_usage_alert"

      filters = {
        product = ["r2_class_a_operations"]
        limit   = ["700000"]
      }
    }
    r2_class_b_operations = {
      name       = "R2 Class B"
      alert_type = "billing_usage_alert"

      filters = {
        product = ["r2_class_b_operations"]
        limit   = ["7000000"]
      }
    }
    cloudflare_tunnel_health = {
      name       = "Cloudflare Tunnel"
      alert_type = "tunnel_health_event"

      filters = {
        "new_status" : [
          "TUNNEL_STATUS_TYPE_DEGRADED",
          "TUNNEL_STATUS_TYPE_DOWN"
        ]
      }
    }
  }
}
