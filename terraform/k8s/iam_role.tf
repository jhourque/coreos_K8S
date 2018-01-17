#### K8S Master ####
resource "aws_iam_policy" "k8s_master" {
  name = "coreos_master"
  path = "/"

  policy = "${file("files/master_policy.json")}"
}

resource "aws_iam_role" "k8s_master" {
  name               = "k8s-master-role"
  assume_role_policy = "${file("files/assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "k8s_master_attach" {
    role       = "${aws_iam_role.k8s_master.name}"
    policy_arn = "${aws_iam_policy.k8s_master.arn}"
}

resource "aws_iam_instance_profile" "k8s_master_profile" {
  name  = "k8s_master_profile"
  role = "${aws_iam_role.k8s_master.name}"
}

#### K8S Node ####
resource "aws_iam_policy" "k8s_node" {
  name = "coreos_node"
  path = "/"

  policy = "${file("files/node_policy.json")}"
}

resource "aws_iam_role" "k8s_node" {
  name               = "k8s-node-role"
  assume_role_policy = "${file("files/assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "k8s_node_attach" {
    role       = "${aws_iam_role.k8s_node.name}"
    policy_arn = "${aws_iam_policy.k8s_node.arn}"
}

resource "aws_iam_instance_profile" "k8s_node_profile" {
  name  = "k8s_node_profile"
  role = "${aws_iam_role.k8s_node.name}"
}
