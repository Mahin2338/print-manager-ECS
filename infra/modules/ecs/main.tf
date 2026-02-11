resource "aws_ecs_cluster" "main" {
  name = "url-shortener-cluster"

  tags = {
    Name = "url-shortener-cluster"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name = "ecs"
  retention_in_days = 7
}



resource "aws_ecs_task_definition" "url-shortener" {
  family                   = "url-shortener"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "url-shortener"
      image     = "754056705747.dkr.ecr.eu-west-2.amazonaws.com/print-manager:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 8080
      hostPort = 8080 }]

      environment = [
        {
          name = "DATABASE_URL"
          value = "postgresql://print:password123@${var.rds_endpoint}/printmanager?sslmode=require"
        
        }
        
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"  = aws_cloudwatch_log_group.app.name
          "awslogs-region" = "eu-west-2"

          "awslogs-stream-prefix" = "ecs"

      } }

  }])




}

resource "aws_ecs_service" "main" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.url-shortener.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.ecs_sg_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_target_group_arn
    container_name   = "url-shortener"
    container_port   = 8080
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "url-shortener-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "ecs_task_role" {
  name = "url-shortener-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

