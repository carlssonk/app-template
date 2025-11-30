
module "cloudflare_zone" {
  source       = "github.com/carlssonk/terraform-modules//compositions/cloudflare-zone?ref=main"
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