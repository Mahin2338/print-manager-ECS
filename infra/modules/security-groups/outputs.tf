output "vpc_endpoints_sg_id" {
  value = aws_security_group.vpc_endpoints.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}