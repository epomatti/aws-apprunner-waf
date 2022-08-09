terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  image_name = "epomatti-sandbox"
}

### ECR Private Repository ###

resource "aws_ecr_repository" "main" {
  name                 = local.image_name
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid       = "SandboxAppRunner"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })
}

### App Runner IAM Role ###

resource "aws_iam_role" "app_runner" {
  name = "SandboxAppRunnerServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "ecr" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role_policy_attachment" "app_runner" {
  role       = aws_iam_role.app_runner.name
  policy_arn = data.aws_iam_policy.ecr.arn
}

# ## App Runner ###

# resource "aws_apprunner_service" "main" {
#   service_name = "sandbox-service"

#   source_configuration {
#     image_repository {
#       image_configuration {
#         port = "80"
#       }
#       image_identifier      = "${aws_ecr_repository.main.repository_url}:latest"
#       image_repository_type = "ECR"
#     }
#     auto_deployments_enabled = true
#   }

#   instance_configuration {
#     instance_role_arn = aws_iam_role.app_runner.arn
#   }

#   tags = {
#     Name = "sandbox-service"
#   }
# }

# output "aws_ecr_repository" {
#   value = aws_ecr_repository.main.repository_url
# }
