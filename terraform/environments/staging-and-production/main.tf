module "website" {
  source      = "github.com/carlssonk/terraform-modules//compositions/cloudflare-cdn-website?ref=main"
  root_domain = "carlssonk.se"
  subdomain = "app-template"

  tags = {
    Environment  = "production"
    Project      = "app-template"
    ManagedBy    = "terraform"
    Repository   = "github.com/carlssonk/app-template"
  }
}