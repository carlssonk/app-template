variable "environment" {
  type        = string
}

variable "root_domain" {
  description = "Domain name for website"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for website (e.g. www, blog, staging)"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}