module "networking" {
  source              = "../../modules/networking"
  vpc_endpoints_sg_id = module.security.vpc_endpoints_sg_id

}

module "security" {
  source   = "../../modules/security-groups"
  vpc_id   = module.networking.vpc_id
  app_port = 8080
  vpc_cidr = module.networking.vpc_cidr_block



}

module "rds" {
  source             = "../../modules/rds"
  private_subnet_ids = module.networking.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  db_password = var.db_password
}

module "ecr" {
  source = "../../modules/ecr"
}

module "ecs" {
  source               = "../../modules/ecs"
  ecs_sg_id            = [module.security.ecs_sg_id]
  private_subnet_ids   = module.networking.private_subnet_ids
  ecs_target_group_arn = module.alb.blue_target_group_arn
  rds_endpoint         = module.rds.rds_endpoint
  db_password          = var.db_password
  container_image      = var.container_image


}

module "alb" {
  source            = "../../modules/alb"
  vpc_id            = module.networking.vpc_id
  alb_sg_id         = module.security.alb_sg_id
  public_subnet_ids = module.networking.public_subnet_ids
}



#tets