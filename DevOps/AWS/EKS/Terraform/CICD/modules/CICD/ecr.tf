#-------------------------------------------------------------------------------------------------
# Description : ECR registry creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "this" {
  name = local.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
