variable "repository_url" {
  type = string
}

variable "access_role_arn" {
  type = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "max_concurrency" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}
