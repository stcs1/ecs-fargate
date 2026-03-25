variable "region" {
  default = "us-east-1"
}

variable "ecs_cluster_name" {
  default = "dev-fargate-cluster"
}

variable "ecs_domain_name" {
    default = "dev-fargate-cluster.example.com"
}

variable "key" {
  default = "terraform.tfstate"
}