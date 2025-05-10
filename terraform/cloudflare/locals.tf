locals {
  zone_write_permission_group = one([for permission_group in data.cloudflare_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "Zone Write"])
  dns_write_permission_group  = one([for permission_group in data.cloudflare_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "DNS Write"])
}
