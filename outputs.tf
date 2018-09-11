output "tempus-challenge-ecs-cluster_id" {
  value = "${element(concat(aws_ecs_cluster.tempus-challenge-ecs-cluster.*.id, list("")), 0)}"
}

output "vpc1_id" {
  value = "${module.vpc1.vpc1_id}"
}

output "vpc2_id" {
  value = "${module.vpc2.vpc2_id}"
}
