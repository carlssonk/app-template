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
    Project      = "app-template"
    Repository   = "github.com/carlssonk/app-template"
  }
}