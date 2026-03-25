terraform {
  backend "s3" {
    key    = "terraform.tfstate"
    bucket = "ecs-fargate-terraform-remotestate-e1"
    region = "us-east-1"
  }
}