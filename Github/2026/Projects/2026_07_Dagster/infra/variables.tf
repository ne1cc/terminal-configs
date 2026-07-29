variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be 'staging' or 'production'."
  }
}

variable "dagster_image" {
  description = "ECR image URI for the Dagster code location"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "db_instance_class" {
  description = "RDS instance class for Dagster run storage"
  type        = string
  default     = "db.t3.micro"
}

variable "desired_count" {
  description = "Number of Dagster daemon/webserver tasks"
  type        = number
  default     = 1
}
