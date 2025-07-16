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