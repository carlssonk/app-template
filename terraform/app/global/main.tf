provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "carlssonk_se_zone" {
  source    = "github.com/carlssonk/terraform-modules//modules/cloudflare-zone?ref=main"
  zone_name = "carlssonk.se"

  settings = {
    ssl = "flexible" # Required for S3 website endpoints
  }
}

# We need this because the website is deployed in the "latest" object
# It adds zero additional latency
module "bucket_path_rewrite" {
  source      = "github.com/carlssonk/terraform-modules//modules/cloudflare-path-prefix?ref=main"
  zone_id     = var.cloudflare_zone_id
  path_prefix = "/latest"
}
