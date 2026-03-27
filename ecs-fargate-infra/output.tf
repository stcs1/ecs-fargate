



output "ecs_alb_listener_arn" {
  value = "${aws_alb_listener.ecs-cluster-listener.arn}"
}

output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.dev-fargate-cluster.name}"
}



output "ecs_domain_name" {
  value = "${var.ecs_domain_name}"
}







