# VPC Endpoints Security Group
resource "aws_security_group" "vpc_endpoints" {
  name        = "ecs-vpc-endpoint"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id
  ingress {
    description = "HTTPS from ECS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [ aws_security_group.ecs.id ]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}


# ALB Security Group
resource "aws_security_group" "alb" {
    name        = "url-shortener-alb-sg"
    description = "Security group for the ALB"
    vpc_id      = var.vpc_id

    ingress {
        description = "HTTP from internet"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS from internet"
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {

        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }


  tags = {
    Name = "alb-sg"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
    name        = "url-shortener-ecs-sg"
    description = "Security group for ECS"
    vpc_id = var.vpc_id

    ingress {
        description     = "Inbound from ALB only"
        protocol        = "tcp"
        from_port       = var.app_port
        to_port         = var.app_port
        security_groups = [aws_security_group.alb.id]
    }

    
    egress {
        description = "Allow all within VPC"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      NAme = "ecs-sg"
    }
}

#  RDS Security Group
resource "aws_security_group" "rds" {
    name        = "url-shortener-rds-sg"
    description = "Security group for rds"
    vpc_id = var.vpc_id

    ingress {
        description     = "Inbound from ECS only"
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        security_groups = [aws_security_group.ecs.id]
    }

    
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      NAme = "rds-sg"
    }
}

