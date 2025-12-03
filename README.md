# App Template

A **simple** production-ready template for deploying Frontend applications to AWS S3 + Cloudflare Workers & CDN, focusing on automated CI/CD pipelines and infrastructure as code.

## Overview

This repository provides a complete setup for modern web application deployment with:

- **Frontend**: Scaffolded vite-react-typescript app
- **Infrastructure**: Terraform-managed AWS S3 + Cloudflare Workers & CDN
- **CI/CD**: GitHub Actions workflows for automated deployments, rollbacks, and releases
- **Multi-Environment**: Support for dev, staging, and production environments
- **Versioned Deployments**: Immutable deployments with rollback capabilities
- **Security**: OIDC authentication for AWS (no long-lived credentials)

## Deployment Philosophy

This template is built around **trunk-based development** principles:

- **Single Branch Deployments** - All changes merge to `main` and deploy automatically to production
- **Gradual Rollouts** - Cloudflare Workers enable progressive traffic shifting between versions (e.g., 90% old version, 10% new version)
- **Fast Rollbacks** - Instant rollback to any previous deployment without rebuilding
- **Immutable Deployments** - Each commit creates a versioned deployment in S3, never overwritten
- **Confidence Through Testing in Production** - Gradual rollouts let you test new versions with real traffic before full deployment

The Cloudflare Worker acts as an intelligent router, enabling gradual rollouts at the infrastructure level. This complements app-level feature flags: use the Worker for large changes (framework upgrades, breaking changes) and app flags for smaller features.

---

# Setup Guide

This guide will help you configure the repository after cloning.

## GitHub Actions Configuration

### 1. Create Environments

Go to **Settings** → **Environments** and create the following environments:

- `dev` (Optional)
- `staging` (Optional)
- `production`
- `infra-approval` (Optional but recommended; used for manual approval of production infrastructure changes)

Recommended Protection Rules for **infra-approval**:
- Required reviewers (add yourself or team members)

### 2. Configure Repository Variables

Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab and create variables with environment suffixes:

| Variable Name | Description | Example Value |
|--------------|-------------|---------------|
| `AWS_ACCOUNT_ID_DEV` | AWS account ID for dev environment | `123456789012` |
| `AWS_ACCOUNT_ID_STAGING` | AWS account ID for staging environment | `123456789012` |
| `AWS_ACCOUNT_ID_PRODUCTION` | AWS account ID for production environment | `123456789012` |
| `S3_BUCKET_DEV` | S3 bucket name for dev environment | `dev.yourdomain.com` |
| `S3_BUCKET_STAGING` | S3 bucket name for staging environment | `staging.yourdomain.com` |
| `S3_BUCKET_PRODUCTION` | S3 bucket name for production environment | `www.yourdomain.com` |
| `AWS_REGION` | AWS region for all environments | `eu-north-1` |

### 3. Configure Environment Secrets

For **each environment** (dev, staging, production), go to **Settings** → **Environments** → select environment → **Secrets** and add:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `BOOTSTRAP_AWS_ACCESS_KEY` | AWS access key for initial Terraform setup | Create IAM user with admin permissions |
| `BOOTSTRAP_AWS_ACCESS_SECRET` | AWS secret key for initial Terraform setup | From the same IAM user |

**Note:** Bootstrap secrets are only needed for the initial Terraform state setup. After bootstrap, workflows use OIDC for AWS authentication.


### 4. Configure Repository Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **Secrets** tab and create:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token for DNS/Workers | Create at Cloudflare Dashboard → My Profile → API Tokens |

**Note:** Make sure your Cloudflare API token has permissions for Workers and DNS.

## Terraform Configuration

Update the following files with your own values:

### `terraform/environments/staging-and-production/staging.tfvars`
```hcl
environment = "staging"
root_domain = "yourdomain.com"                    # Change this
subdomain = "staging.app-template"                # Change this
cloudflare_account_id = "YOUR_CLOUDFLARE_ACCOUNT_ID"  # Change this
```

### `terraform/environments/staging-and-production/production.tfvars`
```hcl
environment = "production"
root_domain = "yourdomain.com"                    # Change this
subdomain = "app-template"                        # Change this
cloudflare_account_id = "YOUR_CLOUDFLARE_ACCOUNT_ID"  # Change this
```

## Quick Start

1. Create GitHub environments (dev, staging, production, infra-approval)
2. Configure repository variables with environment suffixes (AWS_ACCOUNT_ID_*, S3_BUCKET_*, AWS_REGION)
3. Configure environment secrets for each environment (BOOTSTRAP_AWS_ACCESS_KEY & BOOTSTRAP_AWS_ACCESS_SECRET)
4. Configure repository secrets (CLOUDFLARE_API_TOKEN)
5. Update the Terraform `.tfvars` files with your domain and Cloudflare account ID
6. Run the Terraform bootstrap workflow to set up remote state
7. Deploy infrastructure using the Terraform deploy workflow
8. Deploy the app using the app deploy workflow