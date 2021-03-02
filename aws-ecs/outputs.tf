## ---------- NETWORK ----------
output "zone" {
  value = aws_route53_zone.zone.name
}

output "zone_name_servers" {
  value = aws_route53_zone.zone.name_servers
}

output "sg" {
  value = aws_security_group.sg.name
}

output "alb" {
  value = aws_alb.alb.dns_name
}

output "fqdn" {
  value = aws_route53_record.fqdn.name
}

output "tg" {
  value = aws_alb_target_group.tg.arn
}

output "listener" {
  value = aws_alb_listener.listener.arn
}


## ---------- ECR ----------
output "ecr_repo" {
  value = aws_ecr_repository.ecr_repo.repository_url
}


## ---------- CLOUDWATCH ----------
output "log_group" {
  value = aws_cloudwatch_log_group.log_group.name_prefix
}


## ---------- IAM ----------
output "iam_role" {
  value = aws_iam_role.iam_role.name
}

output "iam_policy" {
  value = aws_iam_role_policy.iam_policy.policy
}


## ---------- ECS ----------
output "ecs_cluster" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_task" {
  value = aws_ecs_task_definition.ecs_task.arn
}

output "ecs_service" {
  value = aws_ecs_service.ecs_service.id
}
