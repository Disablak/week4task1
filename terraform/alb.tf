resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Only allow traffic from CloudFront"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from CloudFront"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "13.32.0.0/15",
      "52.46.0.0/18",
      "205.251.192.0/19",
      "54.239.128.0/18"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.private_ec2_webserver[count.index].id
  port             = 80
}

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}