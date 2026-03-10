# vpc module root main.tf
module "vpc" {
  source = "./modules/vpc"

  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

# security module root main.tf
module "security" {
  source = "./modules/security"

  vpc_id                = module.vpc.vpc_id
  project_name          = var.project_name
  raw_bucket_name       = var.raw_images_bucket_name
  processed_bucket_name = var.processed_images_bucket_name
}

# s3 module root main.tf
module "s3" {
  source = "./modules/s3"

  project_name                 = var.project_name
  raw_bucket_name              = var.raw_images_bucket_name
  processed_images_bucket_name = var.processed_images_bucket_name # This matches the module variable
  app_role_arn                 = module.security.app_role_arn
}

# alb module root main.tf
module "alb" {
  source = "./modules/alb"

  name              = "${var.project_name}-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

# web module root main.tf
module "web" {
  source = "./modules/web"

  ami_id            = var.ami_id
  instance_type     = var.web_instance_type
  public_subnet_ids = module.vpc.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  target_group_arn  = module.alb.target_group_arn
}

# app module root main.tf
module "app" {
  source = "./modules/app"

  ami_id                = var.ami_id
  instance_type         = var.app_instance_type
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_sg_id             = module.security.app_sg_id
  raw_bucket_name       = var.raw_images_bucket_name
  processed_bucket_name = var.processed_images_bucket_name # This maps root var to module var
  app_instance_profile  = module.security.app_instance_profile_name
  target_group_arn      = module.alb.app_target_group_arn # Add this line
}

# monitoring module
module "monitoring" {
  source = "./modules/monitoring"

  alb_arn_suffix = module.alb.alb_arn_suffix
  web_asg_name   = module.web.web_asg_name
  app_asg_name   = module.app.app_asg_name
}