output "proxmox_cloudflare_api_token" {
  value     = cloudflare_account_token.proxmox.value
  sensitive = true
}

output "truenas_cloudflare_api_token" {
  value     = cloudflare_account_token.truenas.value
  sensitive = true
}

output "cert_manager_cloudflare_api_token" {
  value     = cloudflare_account_token.cert_manager.value
  sensitive = true
}

output "external_dns_cloudflare_api_token" {
  value     = cloudflare_account_token.external_dns.value
  sensitive = true
}

output "volsync_cloudflare_api_token" {
  value     = cloudflare_account_token.volsync.value
  sensitive = true
}

output "volsync_r2_access_key" {
  value     = cloudflare_account_token.volsync.id
  sensitive = true
}

output "volsync_r2_access_key_secret" {
  value     = sha256(cloudflare_account_token.volsync.value)
  sensitive = true
}

output "postgres_cloudflare_api_token" {
  value     = cloudflare_account_token.postgres.value
  sensitive = true
}

output "postgres_r2_access_key" {
  value     = cloudflare_account_token.postgres.id
  sensitive = true
}

output "postgres_r2_access_key_secret" {
  value     = sha256(cloudflare_account_token.postgres.value)
  sensitive = true
}

output "obsidian_cloudflare_api_token" {
  value     = cloudflare_account_token.obsidian.value
  sensitive = true
}

output "obsidian_r2_access_key" {
  value     = cloudflare_account_token.obsidian.id
  sensitive = true
}

output "obsidian_r2_access_key_secret" {
  value     = sha256(cloudflare_account_token.obsidian.value)
  sensitive = true
}

output "cloudflared_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.homelab.token
  sensitive = true
}
