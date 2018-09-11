output "ec2_1_ids" {
  value = "${aws_instance.Bastion_Host1.*.id}"
}

output "ec2_2_ids" {
  value = "${aws_instance.Bastion_Host2.*.id}"
}

output "amis" {
  value = "${lookup(var.amis, var.region)}"
}
