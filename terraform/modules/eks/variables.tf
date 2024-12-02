variable "security_group_ids" {
  description = "The IDs of the security groups"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "The private subnets"
  type        = list(string)
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}
