resource "aws_ecr_repository" "default" {
  name                 = "apprunner-waf"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
