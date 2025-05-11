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

output "cloudflared_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.homelab.token
  sensitive = true
}
