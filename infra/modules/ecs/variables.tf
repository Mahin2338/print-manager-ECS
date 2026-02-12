variable "container_image" {
 type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = list(string)
}

variable "ecs_target_group_arn" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
  
}

variable "rds_endpoint" {
  type = string
}