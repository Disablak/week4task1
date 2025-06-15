output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

resource "local_file" "migration" {
  content = templatefile("django_run_task.sh.tftpl", {
    public_subnet_0 = module.vpc.public_subnets[0],
    public_subnet_1 = module.vpc.public_subnets[1],
    security_group = aws_security_group.ecs_sg.id,
    task_family = aws_ecs_task_definition.migration.family
  })
  filename = "../run_migration.sh"
}

resource "local_file" "create_superuser" {
  content = templatefile("django_run_task.sh.tftpl", {
    public_subnet_0 = module.vpc.public_subnets[0],
    public_subnet_1 = module.vpc.public_subnets[1],
    security_group = aws_security_group.ecs_sg.id,
    task_family = aws_ecs_task_definition.create_superuser.family
  })
  filename = "../run_create_superuser.sh"
}