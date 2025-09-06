module "iam" {
    source = "./modules/iam"

    providers = {
        aws = aws.perfil-iam
    }

    common_tags = local.tags_phase1
}

module "vpc" {
    source = "./modules/vpc"
    
    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}

module "security-groups" {
    source = "./modules/security-groups"
    vpc_id = module.vpc.vpc_id

    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}

module "bastion" {
    source = "./modules/bastion"
    bastion_sg_id = module.security-groups.bastion_sg_id
    dev_public_subnet_id_1a = module.vpc.dev_public_subnet_id_1a

    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}

module "auto-shutdown" {
    source = "./modules/auto-shutdown"
    
    providers = {
        aws = aws.perfil-autoshutdown
    }

    common_tags = local.tags_phase1
}

module "nat_ec2_gateway" {
    source            = "./modules/instance-gateway"
    ami_id            = "ami-01f23391a59163da9"
    subnet_id         = module.vpc.dev_public_subnet_id_1a
    security_group_id = module.security-groups.gateway_sg_id
    key_name          = "dev-key"
    name              = "dev-gateway-ec2"
    volume_size       = 8
    
    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}

resource "aws_route" "private_nat_route" {
    route_table_id = module.vpc.private_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id = module.nat_ec2_gateway.nat_network_interface_id

    depends_on = [ 
        module.nat_ec2_gateway
    ]
    # This is to secure that the Terraform does not attemps to create the route before the NAT EC2 exists
}

module "nginx" {
    source = "./modules/nginx"
    nginx_sg_id = module.security-groups.nginx_private_sg_id
    dev_private_subnet_id_1a = module.vpc.dev_private_subnet_id_1a

    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}

module "alb" {
    source = "./modules/alb"

    vpc_id          = module.vpc.vpc_id
    public_subnets  = [
        module.vpc.dev_public_subnet_id_1a,
        module.vpc.dev_public_subnet_id_1b 
    ]
    alb_sg_id       = module.security-groups.alb_sg_id
    target_instance_ids = [module.nginx.nginx_instance_id] # We create a list here for the future if the program escalates

    providers = {
        aws = aws.perfil-network
    }

    common_tags = local.tags_phase1
}