resource "aws_security_group" "sg_allow_myip" {
    name        = "sg_allow_myip"
    description = "Allow all access from my ip address"
    vpc_id      = data.aws_vpc.main.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = [ "${chomp(data.http.myip.body)}/32" ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
