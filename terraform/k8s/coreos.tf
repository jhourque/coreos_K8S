variable coreos-name-master {
  type    = "string"
  default = "coreos-master1"
}

variable coreos-name-node {
  type    = "string"
  default = "coreos-node1"
}

variable kubelet_version {
  type    = "string"
  default = "v1.8.5_coreos.0"
}

resource "aws_key_pair" "coreos_keypair" {
  key_name   = "aws-coreos"
  public_key = "${file("~/.ssh/id_rsa.coreos.pub")}"
}


data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"]
}

resource "aws_security_group" "coreos" {
  name        = "${var.coreos-name-master}-servers"
  description = "Coreos K8S traffic"
  vpc_id      = "${module.base_network.vpc_id}"

  tags {
    Name = "${var.coreos-name-master} Servers"
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
  to_port           = "2379"
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

#### K8S Master ####
resource "aws_network_interface" "coreos_master" {
  subnet_id       = "${module.base_network.public_subnets[0]}"
  security_groups = ["${aws_security_group.coreos.id}", "${module.base_network.sg_remote_access}", "${module.base_network.sg_admin}"]
}

resource "aws_iam_policy" "k8s_master" {
  name = "coreos_master"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:UpdateAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role" "k8s_master" {
  name               = "k8s-master-role"
  assume_role_policy = "${file("files/assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "k8s_master_attach" {
    role       = "${aws_iam_role.k8s_master.name}"
    policy_arn = "${aws_iam_policy.k8s_master.arn}"
}

data "template_file" "userdata_master" {
  template = "${file("files/coreos_master.ign")}"

  vars {
    HOSTNAME        = "${var.coreos-name-master}"
    PRIVATE_IPV4    = "${aws_network_interface.coreos_master.private_ips[0]}"
    KUBELET_VERSION = "${var.kubelet_version}"
  }
}

resource "aws_instance" "coreos_master" {
  ami                    = "${data.aws_ami.coreos.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.coreos_keypair.id}"
  user_data              = "${data.template_file.userdata_master.rendered}"

  network_interface {
    network_interface_id = "${aws_network_interface.coreos_master.id}"
    device_index = 0
  }

  tags {
    Name = "${var.coreos-name-master}"
  }
}

#### K8S Node ####
resource "aws_network_interface" "coreos_node" {
  subnet_id       = "${module.base_network.public_subnets[0]}"
  security_groups = ["${aws_security_group.coreos.id}", "${module.base_network.sg_remote_access}", "${module.base_network.sg_admin}"]
}

data "template_file" "userdata_node" {
  template = "${file("files/coreos_node.ign")}"

  vars {
    HOSTNAME     = "${var.coreos-name-node}"
    PRIVATE_IPV4 = "${aws_network_interface.coreos_node.private_ips[0]}"
    PRIVATE_MASTER_IPV4 = "${aws_network_interface.coreos_master.private_ips[0]}"
    KUBELET_VERSION = "${var.kubelet_version}"
  }
}

resource "aws_instance" "coreos_node" {
  ami                    = "${data.aws_ami.coreos.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.coreos_keypair.id}"
  user_data              = "${data.template_file.userdata_node.rendered}"

  network_interface {
    network_interface_id = "${aws_network_interface.coreos_node.id}"
    device_index = 0
  }

  tags {
    Name = "${var.coreos-name-node}"
  }
}

#resource "aws_route53_record" "coreos_dns_record" {
#  zone_id = "${module.private_dns.private_host_zone}"
#  #name    = "${var.coreos-name}"
#  name    = "ip-${replace(aws_instance.coreos.private_ip,"/./","-")}"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_instance.coreos.private_ip}"]
#}
#
#resource "aws_route53_record" "coreos_dns_reverse" {
#  zone_id = "${module.private_dns.private_host_zone_reverse}"
#  name    = "${replace(aws_instance.coreos.private_ip,"/([0-9]+).([0-9]+).([0-9]+).([0-9]+)/","$4.$3")}"
#  type    = "PTR"
#  ttl     = "300"
#  records = ["${aws_instance.coreos.private_ip}.${module.private_dns.private_domain_name}"]
#}


output "coreos_master_public_ip" {
  value = "${aws_instance.coreos_master.public_ip}"
}
output "coreos_master_private_ip" {
  value = "${aws_instance.coreos_master.private_ip}"
}
output "coreos_node_private_ip" {
  value = "${aws_instance.coreos_node.private_ip}"
}