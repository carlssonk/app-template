provider "aws" {
  region = "eu-west-1" # RunsOn does not support all aws regions: https://runs-on.com/guides/install/
}

# Custom GHA Runner
module "runs_on" {
  source      = "github.com/carlssonk/terraform-modules//compositions/runs-on?ref=main"
  license_key = var.runs_on_license_key
  email       = "oliver@carlssonk.se"
  organization =  "carlssonk"
}

# Add other DevOps infrastructure here:
# - Monitoring/observability infrastructure
# - CI/CD tooling
# - Shared build caches
# - Container registries
# - Secret management infrastructure
