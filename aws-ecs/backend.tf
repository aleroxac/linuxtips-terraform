terraform {
  backend "s3" {
    bucket  = "terraform-aleroxac"
    key     = "ecs_cluster.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
