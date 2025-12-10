variable "organization" {
  description = "Github username or organization name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for DevOps infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "runs_on_license_key" {
  description = "License key for runs-on custom GitHub Actions runner"
  type        = string
  sensitive   = true
}

variable "runs_on_email" {
  description = "Email for runs-on registration"
  type        = string
}