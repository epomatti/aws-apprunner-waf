terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source = "./modules/ecr"
}

module "app_runner" {
  source          = "./modules/app-runner"
  cpu             = var.app_runner_cpu
  memory          = var.app_runner_memory
  max_concurrency = var.max_concurrency
  max_size        = var.max_size
  min_size        = var.min_size
  access_role_arn = module.iam.access_role_arn
  repository_url  = module.ecr.repository_url
}

module "waf" {
  source                = "./modules/waf"
  app_runner_arn        = module.app_runner.arn
  allowed_country_codes = var.waf_allowed_country_codes
  rate_limit            = var.waf_rate_limit

  # Metrics
  acl_metrics_enabled           = var.waf_acl_metrics_enabled
  acl_sample_requests_enabled   = var.waf_acl_sample_requests_enabled
  rules_metrics_enabled         = var.waf_rules_metrics_enabled
  rules_sample_requests_enabled = var.waf_acl_sample_requests_enabled
}
