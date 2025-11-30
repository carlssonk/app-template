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

module "cloudflare_zone" {
  source       = "github.com/carlssonk/terraform-modules//modules/cloudflare-zone?ref=main"
  environments = ["production"]
  apps = {
    website = {
      root_domain = "carlssonk.se"
      subdomain   = "app-template"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }
}