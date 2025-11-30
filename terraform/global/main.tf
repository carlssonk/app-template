terraform {
  backend "s3" {}
  
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Zone settings for carlssonk.se
module "carlssonk_se_zone" {
  source    = "github.com/carlssonk/terraform-modules//modules/cloudflare-zone?ref=main"
  zone_name = "carlssonk.se"
  
  settings = {
    ssl = "flexible"  # Required for S3 website endpoints
  }
}