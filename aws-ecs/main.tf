## ---------- NETWORK ----------
resource "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_security_group" "sg" {
  name        = "sg_allow_http"
  description = "Allow all access from my ip address"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "alb" {
  name            = "${var.service_name}-${var.env}-lb"
  subnets         = data.aws_subnet_ids.main_subnets.ids
  security_groups = [aws_security_group.sg.id]
}

resource "aws_route53_record" "fqdn" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${var.service_name}.${var.zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_alb.alb.dns_name]
}

resource "aws_alb_target_group" "tg" {
  name        = "${var.service_name}-${var.env}"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    path     = "/"
    interval = 50
    timeout  = 30
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg.arn
    type             = "forward"
  }
}


## ---------- ECR ----------
resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.service_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

## ---------- CLOUDWATCH ----------
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.service_name}-${var.env}"
  retention_in_days = "7"
}

## ---------- IAM ----------
resource "aws_iam_role" "iam_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = file(
    format("%s/policies/ecs-task-execution-role.json", path.module),
  )
}

resource "aws_iam_role_policy" "iam_policy" {
  name = "ecsTaskExecutionPolicy"
  policy = file(
    format("%s/policies/ecs-execution-role-policy.json", path.module),
  )
  role = aws_iam_role.iam_role.id
}


## ---------- ECS ----------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.env
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # As tasks tem que ter no mínimo 0.25 vCPU e 0.5 GB de memória; os containers podem ter menos recurso computacional
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
  cpu    = var.container_cpu
  memory = var.container_memory

  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  container_definitions = data.template_file.task_definition.rendered
}

resource "aws_ecs_service" "ecs_service" {
  name             = "${var.service_name}-${var.env}"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.ecs_task.arn
  desired_count    = var.app_count
  launch_type      = "FARGATE"
  platform_version = "1.3.0"

  network_configuration {
    security_groups = [aws_security_group.sg.id]
    subnets         = data.aws_subnet_ids.main_subnets.ids

    # Necessário para conseguir fazer pull de imagens docker do Dockerhub, por exemplo
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.tg.id
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [aws_alb_listener.listener]
}
