resource "aws_route53_record" "coreos_dns_record_master" {
  zone_id = "${data.terraform_remote_state.vpc.private_host_zone}"
  #name    = "${var.coreos-name-master}"
  name    = "ip-${replace(aws_instance.coreos_master.private_ip,".","-")}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.coreos_master.private_ip}"]
}

resource "aws_route53_record" "coreos_dns_reverse_master" {
  zone_id = "${data.terraform_remote_state.vpc.private_host_zone_reverse}"
  name    = "${replace(aws_instance.coreos_master.private_ip,"/([0-9]+).([0-9]+).([0-9]+).([0-9]+)/","$4.$3")}"
  type    = "PTR"
  ttl     = "300"
  records = ["${aws_instance.coreos_master.private_ip}.${data.terraform_remote_state.vpc.private_domain_name}"]
}

resource "aws_route53_record" "coreos_dns_record_node" {
  count   = "${var.node-count}"
  zone_id = "${data.terraform_remote_state.vpc.private_host_zone}"
  #name    = "${var.coreos-name-node}"
  name    = "ip-${replace(element(aws_instance.coreos_node.*.private_ip, count.index),".","-")}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.coreos_node.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "coreos_dns_reverse_node" {
  count   = "${var.node-count}"
  zone_id = "${data.terraform_remote_state.vpc.private_host_zone_reverse}"
  name    = "${replace(element(aws_instance.coreos_node.*.private_ip, count.index),"/([0-9]+).([0-9]+).([0-9]+).([0-9]+)/","$4.$3")}"
  type    = "PTR"
  ttl     = "300"
  records = ["${element(aws_instance.coreos_node.*.private_ip, count.index)}.${data.terraform_remote_state.vpc.private_domain_name}"]
}
