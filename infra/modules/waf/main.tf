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

  #################################
  ### Custom Rules
  #################################

  ###  Allow Brazil only ###

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

  ### Rate Limit ###

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
      metric_name                = "kompass-rate-limit"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }


  #################################
  ### Managed Rules
  #################################

  ### Core/Common ###

  rule {
    name     = "aws-common"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "aws-common-metric"
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

  ### Known Bad Inputs ###

  rule {
    name     = "aws-knownbadinputs"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "aws-knownbadinputs-metric"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }

  ### Reputation List ###

  rule {
    name     = "aws-ip-reputation"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "aws-ip-reputation-metric"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }

  ### Anonymous IP List ###

  rule {
    name     = "aws-anonymous-ip"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "aws-anonymous-ip-metric"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }
}

resource "aws_wafv2_web_acl_association" "app_runner" {
  resource_arn = var.app_runner_arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}
