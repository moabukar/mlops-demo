variable "domain_name" {
  description = "The domain name"
  type        = string
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the ALB"
  type        = string
}
