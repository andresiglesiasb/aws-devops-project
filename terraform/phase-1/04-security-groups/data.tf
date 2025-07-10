data "terraform_remote_state" "vpc" {
    backend = "local"
    config = {
      path = "../02-vpc/terraform.tfstate"
    }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}