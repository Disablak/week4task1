resource "aws_ecs_cluster" "fargate_cluster" {
  name = "my-fargate-cluster"
}

locals {
  database_url = format(
    "postgres://%s:%s@%s:%s/%s",
    var.db_username,
    var.db_password,
    aws_db_instance.postgres.address,
    5432,
    var.db_name
  )
}

resource "aws_ecs_task_definition" "app" {
  family                   = "fargate-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "400375466624.dkr.ecr.us-east-1.amazonaws.com/disablak/django-app:latest" # TODO variable
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/fargate-app"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "DJANGO_ALLOWED_HOSTS"
          value = aws_lb.app_lb.dns_name
        },
        {
          name = "DATABASE_URL"
          value = local.database_url
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app" {
  name            = "fargate-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.app_listener]
}