terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3"
    }
    http = {
      source = "hashicorp/http"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}
