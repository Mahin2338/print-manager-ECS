terraform {
  backend "s3" {
    bucket         = "ecs-v2-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

