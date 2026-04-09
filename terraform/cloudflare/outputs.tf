output "dns_write_account_tokens" {
  value     = { for key, token in cloudflare_account_token.dns_write : key => token.value }
  sensitive = true
}

output "r2_bucket_write_account_tokens" {
  value = { for key, token in cloudflare_account_token.r2_bucket_write :
    key => {
      token             = token.value
      access_key        = token.id
      access_key_secret = sha256(token.value)
    }
  }
  sensitive = true
}

output "rclone_cloudflare_api_token" {
  value     = cloudflare_account_token.rclone.value
  sensitive = true
}

output "rclone_r2_access_key" {
  value     = cloudflare_account_token.rclone.id
  sensitive = true
}

output "rclone_r2_access_key_secret" {
  value     = sha256(cloudflare_account_token.rclone.value)
  sensitive = true
}

output "cloudflared_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.homelab.token
  sensitive = true
}
