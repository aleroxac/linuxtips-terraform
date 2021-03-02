provider "aws" {
  region = "us-east-1"
}


## ---------- EC2 ----------
/* module "aws-ec2" {
  source       = "./aws-ec2"
  env          = "prod"
  service_name = "nginx"
}

output "private_key" {
  value = module.aws-ec2.private_key
}

output "public_ip" {
  value = module.aws-ec2.public_ip
} */


## ---------- ECS ----------
module "aws-ecs" {
  source       = "./aws-ecs"
  env          = "dev"
  service_name = "nginx"
}

output "fqdn" {
  value = module.aws-ecs.fqdn
}

output "zone_name_servers" {
  value = module.aws-ecs.zone_name_servers
}

output "ecr_repo" {
  value = module.aws-ecs.ecr_repo
}
