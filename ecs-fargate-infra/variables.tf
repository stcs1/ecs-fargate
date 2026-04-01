variable "region" {
  default = "us-east-1"
}
variable "remote_state_bucket" {}
variable "remote_state_key" {}
variable "remote_state_region" {}

variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "domain_name" {}
variable "ecs_domain_name" {}
variable "key" {}
variable "s3" {}
variable "internet_cidr_block" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "private_subnet_1_cidr" {
  type = string
}

variable "private_subnet_2_cidr" {
  type = string
}
variable "vpc_cidr_block" {}
variable "remote_state_bucket" {}
variable "remote_state_key" {}
variable "remote_state_region" {}




  

  
