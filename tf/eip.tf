# elastic ips

# Associate Elastic IPs to Instances
resource "aws_eip" "dc-eip" {

  count = "${var.node_count}"
  instance = "${element(aws_instance.master.*.id, count.index)}"

  tags = {
    Name = "${var.prefix}_eip${count.index + 1}"
  }

  depends_on = [aws_instance.master]
}
