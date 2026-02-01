resource "aws_ecr_repository" "url-shortener" {
  name                 = "url-shortener"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}


data "aws_ecr_lifecycle_policy_document" "app" {
  rule {
    priority    = 1
    description = "delete last 10 images"

    selection {
      tag_status      = "any"
      count_type      = "imageCountMoreThan"
      count_number    = 5
    }
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.url-shortener.name

  policy = data.aws_ecr_lifecycle_policy_document.app.json
}