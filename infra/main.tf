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

# Modules
module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

module "app_runner" {
  source          = "./modules/app-runner"
  repository_url  = module.ecr.repository_url
  cpu             = var.app_runner_cpu
  memory          = var.app_runner_memory
  max_concurrency = var.max_concurrency
  max_size        = var.max_size
  min_size        = var.min_size
  access_role_arn = module.iam.access_role_arn
}

module "waf" {
  source         = "./modules/waf"
  app_runner_arn = module.app_runner.arn
}
