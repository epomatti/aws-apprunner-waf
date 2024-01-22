

resource "aws_apprunner_service" "main" {
  service_name                   = "dotnet-app"
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  instance_configuration {
    cpu    = var.cpu
    memory = var.memory
  }

  source_configuration {
    auto_deployments_enabled = false

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
    unhealthy_threshold = 3
  }

  observability_configuration {
    observability_enabled           = true
    observability_configuration_arn = aws_apprunner_observability_configuration.main.arn
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "main"

  max_concurrency = var.max_concurrency
  max_size        = var.max_size
  min_size        = var.min_size

  tags = {
    Name = "main-apprunner-autoscaling"
  }
}

resource "aws_apprunner_observability_configuration" "main" {
  observability_configuration_name = "awsxray"

  trace_configuration {
    vendor = "AWSXRAY"
  }
}
