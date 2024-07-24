# Route53 for instances

resource "aws_route53_record" "master" {

  zone_id = "${var.route53_zone_id}"
  count = "${var.node_count}"

  name = "${var.prefix}-master${count.index + 1}.${var.route53_subdomain}.${var.route53_domain}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_eip.dc-eip.*.public_ip, count.index)}"]
}

