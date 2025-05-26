resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Allow internal traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Allow SSH only within the VPC
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow HTTP from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}

resource "aws_instance" "private_ec2" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[count.index].id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              sudo echo "Hello from private EC2 instance ${count.index + 1}" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "private-ec2-${count.index + 1}"
  }
}
