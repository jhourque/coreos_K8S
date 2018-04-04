resource "aws_key_pair" "coreos_keypair" {
  key_name   = "aws-coreos"
  public_key = "${file("~/.ssh/id_rsa.k8s.pub")}"
}

resource "aws_security_group" "coreos" {
  name        = "${var.coreos-name-master}-servers"
  description = "Coreos K8S traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "${var.coreos-name-master} Servers"
    KubernetesCluster = "K8S_cluster"
  }
}

resource "aws_security_group_rule" "coreos_k8s_http" {
  type              = "ingress"
  from_port         = "8080"
  to_port           = "8080"
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}

resource "aws_security_group_rule" "coreos_k8s_internal" {
  type              = "ingress"
  from_port         = "2379"
  to_port           = "2380"
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}

resource "aws_security_group_rule" "coreos_k8s_https" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}

resource "aws_security_group_rule" "coreos_k8s_logs" {
  type              = "ingress"
  from_port         = "10250"
  to_port           = "10250"
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}

resource "aws_security_group_rule" "coreos_k8s_flannel" {
  type              = "ingress"
  from_port         = "8472"
  to_port           = "8472"
  protocol          = "udp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}

resource "aws_security_group_rule" "coreos_k8s_service" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "32767"
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.coreos.id}"
}
