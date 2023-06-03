variable "app_runner_arn" {
  type = string
}

variable "allowed_country_codes" {
  type = list(string)
}

variable "rate_limit" {
  type = number
}

variable "acl_metrics_enabled" {
  type = bool
}

variable "acl_sample_requests_enabled" {
  type = bool
}

variable "rules_metrics_enabled" {
  type = bool
}

variable "rules_sample_requests_enabled" {
  type = bool
}
