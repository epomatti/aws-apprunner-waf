variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "app_runner_cpu" {
  type    = string
  default = "0.5 vCPU"
}

variable "app_runner_memory" {
  type    = string
  default = "1 GB"
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

variable "repository_url" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:latest"
}

variable "image_repository_type" {
  type    = string
  default = "ECR_PUBLIC"
}
