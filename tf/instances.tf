# Instances:

# masters
resource "aws_instance" "master" {

  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
    delete_on_termination = true
  }

  # Second disk for longhorn
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "200"
    volume_type = "gp2"
    delete_on_termination = true
  }

  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  vpc_security_group_ids = ["${aws_security_group.dc-instance-sg.id}"]
  subnet_id = "${aws_subnet.dc-subnet.id}"

  user_data = "${file("userdata.sh")}"

  count = "${var.node_count}"

  tags = {
    #Name = "${var.prefix}-${each.key}"
    Name = "${var.prefix}_master${count.index + 1}"
  }
}

# additional network interfaces
resource "aws_network_interface" "master-nic" {

  count = "${var.node_count}"

  subnet_id       = "${aws_subnet.dc-subnet2.id}"
  security_groups = [aws_security_group.dc-instance-sg.id]

  attachment {
    instance     = "${element(aws_instance.master.*.id, count.index)}"
    device_index = 1
  }

  depends_on = [aws_instance.master]
}

# master1 eth2 nic with a specific IP address value
resource "aws_network_interface" "master-vip-ip" {

  subnet_id       = "${aws_subnet.dc-subnet.id}"
  security_groups = [aws_security_group.dc-instance-sg.id]

  attachment {
    instance     = aws_instance.master[0].id
    device_index = 2
  }

  private_ips = var.private_ips

  depends_on = [aws_instance.master]
}


