provider "aws" {
    region = var.aws_region
}


terraform {
    backend "s3" {
        bucket  = "terraform-aleroxac"
        key     = "ec2_server.tfstate"
        region  = "us-east-1"
        encrypt = true
    }
}