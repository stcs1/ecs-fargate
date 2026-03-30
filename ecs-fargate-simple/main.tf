module "vpc" {
  source = "../modules/vpc"

  region = "us-east-1"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnet1_cidr = "10.0.1.0/24"
  public_subnet2_cidr = "10.0.2.0/24"
}