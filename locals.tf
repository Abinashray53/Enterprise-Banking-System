locals {
  project_prefix = lower(replace(var.project_name, " ", "-"))
  environment    = lower(var.environment)

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Engineering"
  }

  default_resource_name = "${local.project_prefix}-${local.environment}"
}
