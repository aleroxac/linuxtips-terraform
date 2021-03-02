## ---------- INPUT VARIABLES ----------
variable "env" {}
variable "service_name" {}

## ---------- DEFAULT VARIABLES ----------
variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "zone_name" {
  default = "aleroxac.tk"
  type    = string
}

## ---------- ECS ----------
variable "container_cpu" {
  default = 256
  type    = number
}

variable "container_memory" {
  default = 512
  type    = number
}

variable "container_port" {
  default = 80
  type    = number
}

variable "tag_version" {
  default = "latest"
  type    = string
}

variable "app_count" {
  default = 2
  type    = number
}
