variable "repository_url" {
  type = string
}

variable "access_role_arn" {
  type = string
}

resource "aws_apprunner_service" "main" {
  service_name                   = "sandbox-service"
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  instance_configuration {
    cpu    = "2 vCPU"
    memory = "4 GB"
  }

  source_configuration {
    auto_deployments_enabled = true

    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "${var.repository_url}:latest"
      image_repository_type = "ECR"
    }

    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
  }

  health_check_configuration {
    path                = "/"
    unhealthy_threshold = 2
  }

  tags = {
    Name = "sandbox-service"
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "main"

  max_concurrency = 50
  max_size        = 5
  min_size        = 2

  tags = {
    Name = "main-apprunner-autoscaling"
  }
}

output "app_runner_service_url" {
  value = aws_apprunner_service.main.service_url
}
