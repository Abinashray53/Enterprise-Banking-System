module "networking" {

  source = "./modules/networking"

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

}
