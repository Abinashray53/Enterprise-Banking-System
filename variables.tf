variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
  default     = "EnterpriseBankingSystem"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
