output "webserver_ip_addr" {
  value = [for instance in aws_instance.private_ec2_webserver : instance.private_ip]
}

output "database_ip_addr" {
  value = aws_instance.private_ec2_database.private_ip
}

output "dns" {
  value = aws_lb.app_alb.dns_name
}