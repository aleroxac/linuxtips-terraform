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


## ---------- LOCALS ----------
locals {
    ec2_hostname = "${var.service_name}-${var.env}"
}


## ---------- DATA SOURCES ----------
data "aws_vpc" "main" {
    default = true
}

data "aws_subnet_ids" "ec2_subnets" {
    vpc_id = data.aws_vpc.main.id
}

data "aws_ami" "ami_ubuntu" {
    most_recent      = true
    name_regex       = "^ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"
    owners           = ["099720109477"]

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}