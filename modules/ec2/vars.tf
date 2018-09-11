variable "azs" {
  default = []
}

variable "vpc1_id" {}

variable "vpc2_id" {}

variable "subnet1_ids" {
  default = []
}

variable "subnet2_ids" {
  default = []
}

variable "vpc1_bastion_host_sg_id" {}

variable "vpc2_bastion_host_sg_id" {}

variable "region" {}

variable "amis" {
  type = "map"

  default = {
    us-east-1 = "ami-759bc50a"
    us-east-2 = "ami-5e8bb23b"
  }
}
