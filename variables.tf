variable "create_ecs" {
  description = "Controls if ECS should be created"
  default     = true
}

variable "name" {
  default     = "Tempus-Challenge"
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
}

variable "region" {
  default = "us-east-2"
}

variable "azs" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
