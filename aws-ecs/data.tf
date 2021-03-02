data "aws_vpc" "main_vpc" {
  default = true
}

data "aws_subnet_ids" "main_subnets" {
  vpc_id = data.aws_vpc.main_vpc.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {
}

data "template_file" "task_definition" {
  template = file("${path.module}/templates/nginx.json")

  vars = {
    ecr_repo         = aws_ecr_repository.ecr_repo.repository_url
    service_name     = var.service_name
    env              = var.env
    aws_region       = var.aws_region
    tag_version      = var.tag_version
    container_memory = var.container_memory
    container_cpu    = var.container_cpu
    container_port   = var.container_port
  }
}
