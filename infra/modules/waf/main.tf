module "waf_logging" {
  source      = "./logging"
  web_acl_arn = aws_wafv2_web_acl.default.arn
}

### ACL ###
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
      metric_name                = "rate-limit"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }


  #################################
  ### Managed Rules
  #################################

  ### Core/Common ###

  # https://repost.aws/knowledge-center/waf-http-request-body-inspection
  rule {
    name     = "aws-common"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        rule_action_override {
          name = "SizeRestrictions_BODY"

          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.rules_metrics_enabled
      metric_name                = "aws-common-metric"
      sampled_requests_enabled   = var.rules_sample_requests_enabled
    }
  }


  rule {
    name     = "aws-common-size-restriction-body"
    priority = 3

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body"
            scope = "LABEL"
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                positional_constraint = "CONTAINS"
                search_string         = "/put"

                field_to_match {
                  uri_path {}
                }

                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "size-restriction"
      sampled_requests_enabled   = true
    }
  }

  ### Known Bad Inputs ###
  rule {
    name     = "aws-knownbadinputs"
    priority = 4

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
    priority = 5

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
    priority = 6

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

  # SQL Injection
  rule {
    name     = "sqli"
    priority = 7

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
