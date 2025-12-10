provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Global DNS and CDN configuration
# Note: DevOps infrastructure (runs-on) has been moved to terraform/devops
module "carlssonk_se_zone" {
  source    = "github.com/carlssonk/terraform-modules//modules/cloudflare-zone?ref=main"
  zone_name = "carlssonk.se"
  
  settings = {
    ssl = "flexible"  # Required for S3 website endpoints
  }
}