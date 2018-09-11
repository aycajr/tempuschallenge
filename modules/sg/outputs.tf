############## VPC1 ##################

output "vpc1_docker_container_sg_id" {
  value = "${aws_security_group.vpc1_docker_container_sg.id}"
}

output "vpc1_bastion_host_sg_id" {
  value = "${aws_security_group.vpc1_bastion_host_sg.id}"
}

output "vpc1_elb_sg_id" {
  value = "${aws_security_group.elb1.id}"
}

output "aws_default_security_group_id1" {
  value = "${aws_default_security_group.default1.id}"
}

############## VPC2 #################
output "vpc2_docker_container_sg_id" {
  value = "${aws_security_group.vpc2_docker_container_sg.id}"
}

output "vpc2_bastion_host_sg_id" {
  value = "${aws_security_group.vpc2_bastion_host_sg.id}"
}

output "vpc2_elb_sg_id" {
  value = "${aws_security_group.elb2.id}"
}

/*
output "aws_default_security_group_id2" {
  value = "${aws_default_security_group.default2.id}"
}
*/

