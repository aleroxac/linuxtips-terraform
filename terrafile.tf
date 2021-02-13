provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "terraform-aleroxac"
    key     = "ec2_server.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "aws-ec2" {
  source       = "./aws-ec2"
  env          = "prod"
  service_name = "nginx"
}


output "private_key" {
  value = module.aws-ec2.private_key
}

output "public_ip" {
  value = module.aws-ec2.public_ip
}
