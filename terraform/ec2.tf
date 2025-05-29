resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg-webserver"
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
    Name = "private-ec2-webserver-sg"
  }
}

resource "aws_security_group" "private_ec2_sg_database" {
  name        = "private-ec2-sg-database"
  description = "Allow internal traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Allow SSH only within the VPC
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "Allow PSQL"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-databes-sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow ssh my ip"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip_for_bastion]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-databes-sg"
  }
}

resource "aws_instance" "private_ec2_webserver" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[count.index].id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "private-ec2-webserver${count.index + 1}"
  }
}

resource "aws_instance" "private_ec2_database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[2].id // place in third subnet
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg_database.id]
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "private-ec2-database"
  }
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "public-bastion"
  }
}

