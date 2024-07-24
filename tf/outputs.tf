
output "aws-region" {
  value = "${var.region}"
}

# Domain
output "domainname" {
  value = "${var.route53_subdomain}.${var.route53_domain}"
}

# Instances

# public
output "instance-public-eip" {
  value = ["${aws_eip.dc-eip.*.public_ip}"]
}
output "instance-public-ip" {
  value = ["${aws_instance.master.*.public_ip}"]
}

# private
output "instance-private-ip" {
  value = ["${aws_instance.master.*.private_ip}"]
}
output "instance-private-nic2-ip" {
  value = ["${aws_network_interface.master-nic[*].private_ip}"]
}
output "instance-private-nic3-ip" {
  value = ["${aws_network_interface.master-vip-ip.private_ip}"]
}

# DNS names
output "instance-name" {
  value = ["${aws_route53_record.master.*.name}"]
}

