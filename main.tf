##################################
#            MAIN.TF
##################################
provider "aws" {
  region = "${var.region}"
}

provider "terraform" {}

terraform {
  required_version = ">= 0.11.7"
}

provider "template" {
  version = ">= 1.0.0"
}

locals {
  name               = "TempusChallenge"
  environment        = "Lab"
  ec2_resources_name = "${local.name}-${local.environment}"
}

module "vpc1" {
  source = "modules/vpc1"

  vpc1_name = "Tempus-Challenge-VPC1"

  vpc1_cidr = "10.10.0.0/16"

  azs = ["${var.azs}"]

  vpc1_private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  vpc1_public_subnets  = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  vpc1_intra_subnets   = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]

  # database_subnets    = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
  # elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24"]
  # redshift_subnets    = ["10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24"]

  #vpc1_create_database_subnet_group = false
  vpc1_enable_nat_gateway = true
  vpc1_single_nat_gateway = true
  vpc1_enable_vpn_gateway = false

  #vpc1_enable_s3_endpoint       = true
  #vpc1_enable_dynamodb_endpoint = true

  vpc1_elb_sg_id           = "${module.sg1.vpc1_elb_sg_id}"
  vpc1_enable_dhcp_options = true
  #vpc1_dhcp_options_domain_name         = "service.consul"
  #vpc1_dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]
  #vpc1_dhcp_options_domain_name         = "service.consul"
  vpc1_dhcp_options_domain_name_servers = ["8.8.8.8", "8.8.4.4"]
  vpc1_tags = {
    Owner       = "Tempus"
    Environment = "Lab"
    Name        = "Tempus-Challenge-VPC-1"
  }
}

module "vpc2" {
  source = "modules/vpc2"

  vpc2_name = "Tempus-Challenge-VPC2"

  vpc2_cidr = "172.10.0.0/16"

  azs = ["${var.azs}"]

  vpc2_private_subnets = ["172.10.1.0/24", "172.10.2.0/24", "172.10.3.0/24"]
  vpc2_public_subnets  = ["172.10.11.0/24", "172.10.12.0/24", "172.10.13.0/24"]
  vpc2_intra_subnets   = ["172.10.51.0/24", "172.10.52.0/24", "172.10.53.0/24"]

  #vpc2_database_subnets    = ["172.10.21.0/24", "172.10.22.0/24", "172.10.23.0/24"]
  #vpc2_elasticache_subnets = ["172.10.31.0/24", "172.10.32.0/24", "172.10.33.0/24"]
  #vpc2_redshift_subnets    = ["172.10.41.0/24", "172.10.42.0/24", "172.10.43.0/24"]

  #vpc2_create_database_subnet_group = false
  vpc2_enable_nat_gateway = true
  vpc2_single_nat_gateway = true
  vpc2_enable_vpn_gateway = false

  #vpc2_enable_s3_endpoint       = true
  #vpc2_enable_dynamodb_endpoint = true

  vpc2_elb_sg_id           = "${module.sg2.vpc2_elb_sg_id}"
  vpc2_enable_dhcp_options = true
  #vpc2_dhcp_options_domain_name         = "service.consul"
  #vpc2_dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]
  #vpc2_dhcp_options_domain_name         = "service.consul"
  vpc2_dhcp_options_domain_name_servers = ["8.8.8.8", "8.8.4.4"]
  vpc2_tags = {
    Owner       = "Tempus"
    Environment = "Lab"
    Name        = "Tempus-Challenge-VPC-2"
  }
}

resource "aws_ecs_cluster" "tempus-challenge-ecs-cluster" {
  count = "${var.create_ecs ? 1 : 0}"
  name  = "default"
}

module "ec2-profile" {
  source = "modules/ecs-instance-profile"
  name   = "${local.name}-EC2-profile"
}

module "aws-asg1" {
  source                  = "modules/aws-asg"
  iam_instance_profile_id = "${module.ec2-profile.ecsiamrole1_iam_instance_profile_id}"
  vpc_zone_identifier     = "${module.vpc1.vpc1_private_subnets}"
  name                    = "TC-ECS-1"
  security_groups         = ["${module.sg1.vpc1_docker_container_sg_id}"]
}

module "aws-asg2" {
  source                  = "modules/aws-asg"
  iam_instance_profile_id = "${module.ec2-profile.ecsiamrole1_iam_instance_profile_id}"
  vpc_zone_identifier     = "${module.vpc2.vpc2_private_subnets}"
  name                    = "TC-EC2-Cluster2"
  security_groups         = ["${module.sg2.vpc2_docker_container_sg_id}"]
}

module "hello-world" {
  source     = "service-hello-world"
  cluster_id = "${element(concat(aws_ecs_cluster.tempus-challenge-ecs-cluster.*.id, list("")), 0)}"
}

module "sg1" {
  source  = "modules/sg"
  vpc1_id = "${module.vpc1.vpc1_id}"
  vpc2_id = "${module.vpc2.vpc2_id}"
}

module "sg2" {
  source  = "modules/sg"
  vpc1_id = "${module.vpc1.vpc1_id}"
  vpc2_id = "${module.vpc2.vpc2_id}"
}

module "BH1" {
  source                  = "modules/ec2"
  vpc1_id                 = "${module.vpc1.vpc1_id}"
  vpc2_id                 = "${module.vpc2.vpc2_id}"
  subnet1_ids             = ["${module.vpc1.vpc1_public_subnets}"]
  subnet2_ids             = ["${module.vpc2.vpc2_public_subnets}"]
  vpc1_bastion_host_sg_id = "${module.sg1.vpc1_bastion_host_sg_id}"
  vpc2_bastion_host_sg_id = "${module.sg2.vpc2_bastion_host_sg_id}"
  azs                     = ["${var.azs}"]
  region                  = "${var.region}"
}

module "BH2" {
  source                  = "modules/ec2"
  vpc1_id                 = "${module.vpc1.vpc1_id}"
  vpc2_id                 = "${module.vpc2.vpc2_id}"
  subnet1_ids             = ["${module.vpc1.vpc1_public_subnets}"]
  subnet2_ids             = ["${module.vpc2.vpc2_public_subnets}"]
  vpc1_bastion_host_sg_id = "${module.sg1.vpc1_bastion_host_sg_id}"
  vpc2_bastion_host_sg_id = "${module.sg2.vpc2_bastion_host_sg_id}"
  azs                     = ["${var.azs}"]
  region                  = "${var.region}"
}
