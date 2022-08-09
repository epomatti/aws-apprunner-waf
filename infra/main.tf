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

### App Runner IAM Role ###

resource "aws_iam_role" "access_role" {
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

resource "aws_iam_role_policy_attachment" "access_role" {
  role       = aws_iam_role.access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

## App Runner ###

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

#     authentication_configuration {
#       access_role_arn = aws_iam_role.access_role.arn
#     }
#   }

#   tags = {
#     Name = "sandbox-service"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.access_role
#   ]
# }

# output "aws_ecr_repository" {
#   value = aws_ecr_repository.main.repository_url
# }

# output "app_runner_service_url" {
#   value = aws_apprunner_service.main.service_url
# }
