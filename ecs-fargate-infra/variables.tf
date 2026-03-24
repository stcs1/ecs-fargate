variable "region" {
  default = "us-east-1"
}

variable "ecs_cluster_name" {
  default = "dev-fargate-cluster"
}

variable "ecs_domain_name" {
  
}

variable "s3" {
  default = "ecs-fargate-infra-state"
}

variable "key" {
  default = "terraform.tfstate"
}