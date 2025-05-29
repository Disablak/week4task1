output "webserver_ip_addr" {
  value = [for instance in aws_instance.private_ec2_webserver : instance.private_ip]
}

output "database_ip_addr" {
  value = aws_instance.private_ec2_database.private_ip
}

output "dns" {
  value = aws_lb.app_alb.dns_name
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

resource "local_file" "generated_inv" {
  content = templatefile("inventory.tftpl", {
    web_ip1 = aws_instance.private_ec2_webserver[0].private_ip,
    web_ip2 = aws_instance.private_ec2_webserver[1].private_ip,
    db_ip3 = aws_instance.private_ec2_database.private_ip,
    dns = aws_lb.app_alb.dns_name,
    bastion_ip = aws_instance.bastion.public_ip
  })
  filename = "../ansible/generated_inventory.ini"
}