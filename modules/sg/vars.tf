variable "vpc1_id" {}

variable "vpc2_id" {}

variable "http_https_docker_container_ingress_IP" {
  type    = "list"
  default = ["0.0.0.0/0"]
}
