module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false # for externl vpc connection (on prem)

  enable_dns_hostnames = true 
  enable_dns_support = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}



# S3 Endpoint . Gateway Endpoint. ECR stores Docker image layers in S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-2.s3"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name = "s3-endpoint"
  }
}


# ECR Endpoint ECS calls ECR API to Authenticate
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-api-endpoint"
  }
}

# ECR Docker Endpoint ECS uses Docker Ap to pull images
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-docker-endpoint"
  }
}

# CloudWatch Endpoint ECS sneds container logs to CloudWatch
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "cloudwatch-endpoint"
  }
}

# ECS Endpoint ECS tasks calls ECS api for task metdat health status reporting
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-2.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [var.vpc_endpoints_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ecs-endpoint"
  }
}