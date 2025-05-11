locals {
  dns_write_permission_group = one([for permission_group in data.cloudflare_account_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "DNS Write"])
}
