#### K8S Master ####
resource "aws_network_interface" "coreos_master" {
  subnet_id       = "${data.terraform_remote_state.vpc.public_subnets[0]}"
  security_groups = ["${aws_security_group.coreos.id}", "${data.terraform_remote_state.vpc.sg_remote_access}", "${data.terraform_remote_state.vpc.sg_admin}"]
  # Add route Destination 10.3.0.0/16 in SUB_PUB0 to allow bastion to access k8s services
  source_dest_check      = "false"
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

  iam_instance_profile ="${aws_iam_instance_profile.k8s_master_profile.name}"

  tags {
    Name = "${var.coreos-name-master}"
    KubernetesCluster = "K8S_cluster"
  }
}
