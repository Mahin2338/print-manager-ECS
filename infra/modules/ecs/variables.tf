variable "container-image" {
  type = string
}

variable "private_subnet_ids" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "ecs_target_group_arn" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}