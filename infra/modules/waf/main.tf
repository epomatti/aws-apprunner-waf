resource "aws_wafv2_web_acl" "default" {
  name        = "waf-apprunner"
  description = "App Runner WAF"
  scope       = "REGIONAL"

  default_action {
    allow {}
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
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "app_runner" {
  resource_arn = var.app_runner_arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}
