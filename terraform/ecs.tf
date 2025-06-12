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
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_image
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

resource "aws_ecs_task_definition" "migration" {
  family                   = "django-migration"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "migrate"
      image     = var.app_image
      essential = true
      command   = ["python", "manage.py", "migrate"]
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

resource "aws_ecs_task_definition" "create_superuser" {
  family                   = "django-create-superuser"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "create-superuser"
      image     = var.app_image
      essential = true
      command   = ["python", "manage.py", "createsuperuser", "--noinput"]
      environment = [
        {
          name  = "DJANGO_ALLOWED_HOSTS"
          value = aws_lb.app_lb.dns_name
        },
        {
          name = "DATABASE_URL"
          value = local.database_url
        },
        {
          name = "DJANGO_SUPERUSER_USERNAME"
          value = var.superuser_username
        },
        {
          name = "DJANGO_SUPERUSER_PASSWORD"
          value = var.superuser_password
        },
        {
          name = "DJANGO_SUPERUSER_EMAIL"
          value = var.superuser_email
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