variable "hosted_zone_id" {
description = "Route 53 hosted zone ID"
type        = string
}

variable "domain_name" {
description = "Domain name "
type        = string
}

variable "alb_dns_name" {
description = "ALB DNS name"
type        = string
}

variable "alb_zone_id" {
description = "ALB zone ID"
type        = string
}