variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "app_runner_cpu" {
  type    = string
  default = "2 vCPU"
}

variable "app_runner_memory" {
  type    = string
  default = "4 GB"
}

variable "max_concurrency" {
  type    = number
  default = 50
}

variable "max_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

### WAF ###

variable "waf_allowed_country_codes" {
  type    = list(string)
  default = ["BR"]
}

variable "waf_rate_limit" {
  type    = number
  default = 100
}

variable "waf_acl_metrics_enabled" {
  type    = bool
  default = true
}

variable "waf_acl_sample_requests_enabled" {
  type    = bool
  default = true
}

variable "waf_rules_metrics_enabled" {
  type    = bool
  default = true
}

variable "waf_rules_sample_requests_enabled" {
  type    = bool
  default = true
}

