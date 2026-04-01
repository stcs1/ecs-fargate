variable "image_url" {
  description = "The Docker image URL for the ECS task"
  type        = string
}

data "terraform_remote_state" "platform" {
    backend = "s3"
    config = {
        region = var.remote_state_region
        bucket = var.remote_state_bucket
        key    = var.remote_state_key
    }
}

data "template_file" "ecs_task_definition_template" {
  template = file("${path.module}/ecs_task_definition_template.json")

  vars = {
    image_url = var.image_url
  }
  
}

locals {
    task_definition_json = data.template_file.ecs_task_definition_template.rendered
    ecs_service_name = "${var.ecs_cluster_name}-service"
    docker_image_url = var.image_url
    memory = 512
    cpu = 256
    region = var.region
}

resource "aws_ecs_task_definition" "my-task-definition" {
  family                   = var.ecs_cluster_name
  container_definitions    = data.template_file.ecs_task_definition_template.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = data.terraform_remote_state.platform.ecs_task_execution_role_arn
  task_role_arn            = data.terraform_remote_state.platform.ecs_task_execution_role_arn
}


resource "aws_security_group" "app_security_group" {
  name = "${var.ecs_cluster_name}-app-sg"
  description = "Security group for ECS tasks in ${var.ecs_cluster_name}"
  vpc_id = data.terraform_remote_state.ecs_fargate_infra.outputs.vpc_id

  ingress = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "key" = "var.ecs_service_name"-"app-sg"
  }
}

resource "aws_alb_target_group" "ecs_app_tg" {
  name = "${var.ecs_service_name}-app-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.ecs_fargate_infra.outputs.vpc_id
  target_type = "ip"

  health_check {
    path = "actuator/health"
    protocol = "HTTP"
    matcher = "200"
    interval = 60
    timeout = 30
    unhealthy_threshold = "3"
    healthy_threshold = "3"
  }

  tags = {
    "key" = "${var.ecs_service_name}-app-tg"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name = "${var.ecs_service_name}"
  task_definition = aws_ecs_task_definition.my-task-definition.arn
  desired_count = 1
  launch_type = "FARGATE"
  cluster = data.terraform_remote_state.ecs_fargate_infra.outputs.ecs_cluster_id
  network_configuration {
    subnets = data.terraform_remote_state.ecs_fargate_infra.outputs.public_subnets
    security_groups = [aws_security_group.app_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_app_tg.arn
    container_name = "app"
    container_port = 80
    
  }
}

resource "aws_alb_listener" "ecs_alb_listner_role" {
  load_balancer_arn = data.terraform_remote_state.ecs_fargate_infra.outputs.alb_arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_tg.arn
  }
}

resource "aws_lb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = aws_alb_listener.ecs_alb_listner_role.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_tg.arn
  }
  condition {
    host_header {
      values = ["${var.ecs_service_name}.${var.domain_name}"]
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "${var.ecs_service_name}-logs"
}
