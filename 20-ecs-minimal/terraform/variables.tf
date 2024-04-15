variable "aws_account_id" {
  type        = string
  description = "The AWS account id"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}

variable "aws_zones" {
  type        = list(string)
  description = "The AWS zones to use, at least two required"
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster to create (used as base name for other resources)"
}
