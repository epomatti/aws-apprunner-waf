output "aws_ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_runner_service_url" {
  value = module.app_runner.service_url
}
