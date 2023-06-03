resource "aws_wafv2_web_acl" "default" {
  name        = "waf-apprunner"
  description = "App Runner WAF"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  custom_response_body {
    content      = "You've been WAFed 🔥"
    content_type = "TEXT_PLAIN"
    key          = "wafed"
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
      block {
        custom_response {
          custom_response_body_key = "wafed"
          response_code            = 403
        }
      }
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
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "allowed-contries"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {
        custom_response {
          custom_response_body_key = "wafed"
          response_code            = 403
        }
      }
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = var.rate_limit
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "rate-limit"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }

  rule {
    name     = "sqli"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "sqli-metric"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }

}

resource "aws_wafv2_web_acl_association" "app_runner" {
  resource_arn = var.app_runner_arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}
