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

# Bucket name = "{subdomain}.{root_domain}"
module "website" {
  source      = "github.com/carlssonk/terraform-modules//compositions/cloudflare-cdn-website?ref=main"
  root_domain = var.root_domain
  subdomain = var.subdomain

  index_document = "main/index.html"

  tags = {
    Environment  = var.environment
    Project      = "app-template"
    ManagedBy    = "terraform"
    Repository   = "github.com/carlssonk/app-template"
  }
}