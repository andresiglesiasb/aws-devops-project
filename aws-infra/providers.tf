provider "aws" {
    alias = "perfil-iam"
    region = var.aws_region
    profile = "terraform-iam"
}

provider "aws" {
    alias = "perfil-network"
    region = var.aws_region
    profile = "terraform-network"
}

provider "aws" {
    alias = "perfil-autoshutdown"
    region = var.aws_region
    profile = "terraform-autoshutdown"
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform-network"
}