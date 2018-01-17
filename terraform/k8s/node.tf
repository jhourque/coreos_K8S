#### K8S Node ####
resource "aws_network_interface" "coreos_node" {
  count           = "${var.node-count}"
  subnet_id       = "${data.terraform_remote_state.vpc.public_subnets[0]}"
  security_groups = ["${aws_security_group.coreos.id}", "${data.terraform_remote_state.vpc.sg_remote_access}", "${data.terraform_remote_state.vpc.sg_admin}"]
}

data "template_file" "userdata_node" {
  count    = "${var.node-count}"
  template = "${file("files/coreos_node.ign")}"

  vars {
    HOSTNAME            = "${var.coreos-name-node}${count.index}"
    PRIVATE_IPV4        = "${element(aws_network_interface.coreos_node.*.private_ips[count.index], 0)}"
    PRIVATE_MASTER_IPV4 = "${aws_network_interface.coreos_master.private_ips[0]}"
    KUBELET_VERSION     = "${var.kubelet_version}"
  }
}

resource "aws_instance" "coreos_node" {
  count                  = "${var.node-count}"
  ami                    = "${data.aws_ami.coreos.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.coreos_keypair.id}"
  user_data              = "${element(data.template_file.userdata_node.*.rendered, count.index)}"

  network_interface {
    network_interface_id = "${element(aws_network_interface.coreos_node.*.id, count.index)}"
    device_index = 0
  }

  iam_instance_profile ="${aws_iam_instance_profile.k8s_node_profile.name}"

  tags {
    Name = "${var.coreos-name-node}${count.index+1}"
    KubernetesCluster = "K8S_cluster"
  }
}
