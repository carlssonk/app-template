provider "aws" {
  region = var.aws_region
}

# Custom GHA Runner
module "runs_on" {
  source      = "github.com/carlssonk/terraform-modules//compositions/runs-on?ref=main"
  license_key = var.runs_on_license_key
  email       = var.runs_on_email
}

# Add other DevOps infrastructure here:
# - Monitoring/observability infrastructure
# - CI/CD tooling
# - Shared build caches
# - Container registries
# - Secret management infrastructure



