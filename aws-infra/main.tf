module "iam" {
    source = "./modules/iam"

    providers = {
        aws = aws.perfil-iam
    }
}

module "vpc" {
    source = "./modules/vpc"
    
    providers = {
        aws = aws.perfil-network
    }
}

module "security-groups" {
    source = "./modules/security-groups"
    vpc_id = module.vpc.vpc_id

    providers = {
        aws = aws.perfil-network
    }
}

module "bastion" {
    source = "./modules/bastion"
    bastion_sg_id = module.security-groups.bastion_sg_id
    dev_public_subnet_id_1a = module.vpc.dev_public_subnet_id_1a

    providers = {
        aws = aws.perfil-network
    }
}