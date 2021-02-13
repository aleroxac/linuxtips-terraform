## ---------- INPUT VARIABLES ----------
variable "env" {}
variable "service_name" {}


## ---------- DEFAULT VARIABLES ----------
variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "instance_count" {
  default = 1
  type    = number
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ec2_disk_size" {
  default = 10
  type    = number
}
