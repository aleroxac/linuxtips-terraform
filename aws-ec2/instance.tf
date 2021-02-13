resource "random_shuffle" "subnets" {
  input        = data.aws_subnet_ids.ec2_subnets.ids
  result_count = 1
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ami_ubuntu.id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.sg_allow_myip.id]
  subnet_id                   = random_shuffle.subnets.result[0]
  instance_type               = var.instance_type
  associate_public_ip_address = true

  /* user_data = file("./resources/provisioner.sh") */
  user_data = file("${path.module}/resources/provisioner.sh")

  tags = {
    Name        = local.ec2_hostname
    environment = var.env
    service     = var.service_name
  }
  root_block_device {
    volume_size           = var.ec2_disk_size
    delete_on_termination = true
  }

  timeouts {
    create = "30m"
    delete = "15m"
    update = "15m"
  }
}
