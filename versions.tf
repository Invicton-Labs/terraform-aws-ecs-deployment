terraform {
  required_version = ">= 1.2.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.12.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.26"
    }
  }
}
