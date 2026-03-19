variable "region" {
  default = "us-east-1"
  description = "aws-region"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "public_subnet_1_cidr" {
  description = "Public Subnet 1 cidr"
}

variable "public_subnet_2_cidr" {
  description = "Public Subnet 2 cidr"
}

variable "public_subnet_3_cidr" {
  description = "Public Subnet 3 cidr"
}

variable "private_subnet-1-cidr" {
  description = "Private-Subnet 1 CIDR"
}

variable "private_subnet-2-cidr" {
  description = "Private-Subnet 2 CIDR"
}

variable "private_subnet-3-cidr" {
  description = "Private-Subnet 3 CIDR"
}

