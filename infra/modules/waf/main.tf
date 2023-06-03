resource "aws_wafv2_web_acl" "default" {
  name        = "waf-apprunner"
  description = "App Runner WAF"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.acl_metrics_enabled
    metric_name                = "waf-apprunner-acl-metric"
    sampled_requests_enabled   = var.acl_sample_requests_enabled
  }

  rule {
    name     = "allowed-contries"
    priority = 0

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = var.allowed_country_codes
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "allowed-contries"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 100
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rate-limit"
      sampled_requests_enabled   = false
    }
  }

}

resource "aws_wafv2_web_acl_association" "app_runner" {
  resource_arn = var.app_runner_arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}
