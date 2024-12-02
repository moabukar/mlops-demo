provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
  azs          = var.availability_zones
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  environment        = var.environment
  security_group_ids = [module.security_groups.eks_security_group_id]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.repository_name
  environment     = var.environment
}

module "rds" {
  source = "./modules/rds"

  identifier  = "${var.environment}-ml-db"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  environment = var.environment
}

module "elasticache" {
  source = "./modules/elasticache"

  cluster_id  = "${var.environment}-ml-cache"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  environment = var.environment
}

module "s3" {
  source = "./modules/s3"

  bucket_name = "${var.environment}-ml-storage"
  environment = var.environment
}

module "route53" {
  source = "./modules/route53"

  domain_name = var.domain_name
  environment = var.environment
}

module "security_groups" {
  source = "./modules/security_groups"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}