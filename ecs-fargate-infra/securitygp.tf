resource "aws_security_group" "ecs-alb-sg" {
  name = "${var.ecs_cluster_name}-alb-sg"
  description = "Security group for ALB in ${var.ecs_cluster_name} cluster"
  vpc_id = data.terraform_remote_state.ecs_fargate_infra.vpc_id
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

} 