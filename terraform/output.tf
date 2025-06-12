output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}