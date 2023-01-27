module "vpc" {
  source                    = "../modules/vpc"
  vpc_cidr_block            = "10.0.0.0/16"
  availability_zones        = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnet_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr_block = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "ecr" {
  source = "../modules/ecr"
}

module "oidc_github" {
  source = "../modules/oidc/github"
}

module "ecs" {
  source                     = "../modules/ecs"
  repository_url             = module.ecr.application_repository_url
  application_container_port = 3333
  private_subnet_ids         = module.vpc.private_subnet_ids
  public_subnet_ids          = module.vpc.public_subnet_ids
  vpc_id                     = module.vpc.id
}