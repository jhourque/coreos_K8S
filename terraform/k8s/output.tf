output "coreos_master_public_ip" {
  value = "${aws_instance.coreos_master.public_ip}"
}
output "coreos_master_private_ip" {
  value = "${aws_instance.coreos_master.private_ip}"
}
output "coreos_node_private_ip" {
  value = "${aws_instance.coreos_node.*.private_ip}"
}
