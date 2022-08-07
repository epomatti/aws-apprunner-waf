terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "default" {
  repository_name = "epomatti-sandbox"

  catalog_data {
    about_text        = "Sandbox repository"
    architectures     = ["x86-64"]
    description       = "Sandbox repository"
    operating_systems = ["Linux"]
  }
}

output "repository_uri" {
  value = aws_ecrpublic_repository.default.repository_uri
}
