terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Modules
module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

# module "app_runner" {
#   source          = "./modules/app-runner"
#   repository_url  = module.ecr.repository_url
#   access_role_arn = module.iam.access_role_arn
# }


# Output

output "aws_ecr_repository_url" {
  value = module.ecr.repository_url
}

# output "app_runner_service_url" {
#   value = module.app_runner.app_runner_service_url
# }
