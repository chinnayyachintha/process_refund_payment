# AWS Region where resources will be deployed
variable "aws_region" {
  type        = string
  description = "AWS Region to deploy resources"
}

# Project name to be used as a prefix for all resources
variable "project_name" {
  type        = string
  description = "Project name to be used as a prefix for all resources"
}

# Tags to be assigned to resources
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
}

# Elavon API URL and Token for refund processing
variable "elavon_api_url" {
  description = "The Elavon API endpoint URL"
  type        = string
}

# Elavon API Token for authentication
variable "elavon_api_token" {
  description = "The Elavon API token for authentication"
  type        = string
}