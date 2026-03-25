provider "aws" {
  region = var.region
}

data "terraform_remote_state" "ecs_fargate_infra" {
  backend = "s3"

  config = {
    bucket = "ecs-fargate-terraform-remotestate"
    key    = "path/to/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecs_cluster" "dev-fargate-cluster" {
  name = "dev-fargate-cluster"
}

resource "aws_security_group" "ecs_alb_security_group" {
  name = "${var.ecs_cluster_name}-alb-sg"
  description = "Security group for ALB in ${var.ecs_cluster_name}"
  vpc_id = data.terraform_remote_state.ecs_fargate_infra.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.internet_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.internet_cidr_blocks
  }
}

resource "aws_alb" "ecs_cluster_alb" {
  name            = "${var.ecs_cluster_name}-alb"
  internal        = false
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets         = data.terraform_remote_state.ecs_fargate_infra.public_subnet_ids

  tags = {
    Name = "${var.ecs_cluster_name}-alb"
  }
}

resource "aws_route53_record" "ecs_alb_record" {
  name    = "$*.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain_zone.zone_id

  alias {
    evaluate_target_health = false
    name = "aws_alb.ecs_cluster_alb.dns_name"
    zone_id = "${aws_alb.ecs_cluster_alb.zone_id}"
  }
}

resource "aws_alb_target_group" "ecs-cluster-tg" {
  name     = "${var.ecs_cluster_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.ecs_fargate_infra.vpc_id

  tags = {
    Name = "${var.ecs_cluster_name}-tg"
  }
}

resource "aws_alb_listener" "ecs-cluster-listener" {
  load_balancer_arn = aws_alb.ecs-cluster-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ecs_domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-cluster-tg.arn
  }

    depends_on = [aws_alb_target_group.ecs-cluster-tg]
}

resource "aws_iam_role" "ecs-cluster-role" {
    name = "${var.ecs_cluster_name}-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "ecs.amazonaws.com"
            }
        }
        ]
    })
    
    tags = {
        Name = "${var.ecs_cluster_name}-role"
    }
  
}

resource "aws_iam_role_policy_attachment" "ecs-cluster-role-attachment" {
    role       = aws_iam_role.ecs-cluster-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

