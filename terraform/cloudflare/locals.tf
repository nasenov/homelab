locals {
  dns_write_permission_group       = one([for permission_group in data.cloudflare_account_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "DNS Write"])
  r2_bucket_write_permission_group = one([for permission_group in data.cloudflare_account_api_token_permission_groups_list.permission_groups.result : permission_group if permission_group.name == "Workers R2 Storage Bucket Item Write"])
}
