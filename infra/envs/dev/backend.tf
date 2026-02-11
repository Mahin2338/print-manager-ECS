terraform {
  backend "s3" {
    bucket = "ecs-v2-bucket"
    key    = "envs/dev/terraform.tfstate"
    region = "eu-west-2"
    encrypt = true 
    dynamodb_table = "terraform-locks"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}