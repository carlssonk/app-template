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

# Create KV namespace for storing version info
resource "cloudflare_workers_kv_namespace" "version" {
  account_id = var.cloudflare_account_id
  title      = "${var.environment}-app-version"
}

# Bucket name = "{subdomain}.{root_domain}"
module "website" {
  source      = "github.com/carlssonk/terraform-modules//compositions/cloudflare-cdn-website?ref=main"
  root_domain = var.root_domain
  subdomain = var.subdomain

  index_document = "main/index.html"

  enable_worker = true
  worker_script = file("${path.module}/worker.js")
  
  worker_plain_text_bindings = {
    S3_BUCKET_NAME = "${var.subdomain}.${var.root_domain}"
  }

  # Bind KV namespace to worker
  worker_kv_namespace_bindings = {
    VERSION_KV = cloudflare_workers_kv_namespace.version.id
  }

  tags = {
    Environment  = var.environment
    Project      = "app-template"
    ManagedBy    = "terraform"
    Repository   = "github.com/carlssonk/app-template"
  }
}