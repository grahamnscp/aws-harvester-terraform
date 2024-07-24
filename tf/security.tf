# Security

resource "aws_security_group" "dc-instance-sg" {
  name        = "${var.prefix}-${random_string.suffix.result}"
  description = "Allow inbound traffic"
  vpc_id      = "${aws_vpc.dc-vpc.id}"

  # allow all ping
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow self
  ingress {
    description      = "Self"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  # allow all for internal subnet
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${aws_subnet.dc-subnet.cidr_block}"]
  }

  # open all for specific ips
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.ip_cidr_me}","${var.ip_cidr_work}"]
  }


  # egress out for all
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

