variable "app_image" {
  type = string
  default = "400375466624.dkr.ecr.us-east-1.amazonaws.com/disablak/django-app:latest"
}

variable "fargate_cpu" {
  type = string
  default = "256"
}

variable "fargate_memory" {
  type = string
  default = "512"
}

# db creds

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type = string
}

# super user creds

variable "superuser_username" {
  type = string
}

variable "superuser_password" {
  type = string
  sensitive = true
}

variable "superuser_email" {
  type = string
}