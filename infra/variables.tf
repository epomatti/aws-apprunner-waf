variable "aws_region" {
  type    = string
  default = "us-east-1"
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
  default = 5
}

variable "min_size" {
  type    = number
  default = 2
}
