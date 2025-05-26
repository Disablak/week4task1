# VPC 
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EC2
variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  # Amazon Linux 2 AMI (you can change this to your preferred AMI)
  default = "ami-0c02fb55956c7d316"
}

variable "key_name" {
  default = "key-us-east-1"
}