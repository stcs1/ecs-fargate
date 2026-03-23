# provider "aws" {
#   region = "${var.region}"
# }

# terraform {
#   backend "s3" {}
# }

# data "terraform_remote_state" "ecs_fargate_infra" {
#     backend = "s3"
#     config = {
#         bucket = "ecs-fargate-infra-state"
#         key    = "terraform.tfstate"
#         region = "${var.region}"
#     }
# }

resource "aws_ecs_cluster" "dev-fargare-cluster" {
  name = "dev-fargate-cluster"

}

resource "aws_alb" "ecs-cluster-alb" {
  name = "${var.ecs_cluster_name}-alb"
  internal = false
  security_groups = [aws_security_group.ecs-alb-sg.id]
  subnets = data.terraform_remote_state.ecs_fargate_infra.public_subnet_ids

  tags = {
    Name = "${var.ecs_cluster_name}-alb"
  }
}

resource "aws_route53_record" "ecs_alb_record" {
  name = "${var.ecs_cluster_name}.${var.domain_name}"
  type = "CNAME"
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  records = [aws_alb.ecs-cluster-alb.dns_name]
  ttl = 60
}

resource "aws_alb_target_group" "ecs-cluster-tg" {
  name = "${var.ecs_cluster_name}-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.ecs_fargate_infra.vpc_id

  tags = {
    Name = "${var.ecs_cluster_name}-tg"
  }
}
