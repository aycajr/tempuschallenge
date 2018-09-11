#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#  ,@@@@@@@@.  @@        @@@@@@@@*        @@@@@@@@@@@@,,@@@@
#@  @@@@@@@@  @@@  @@@@@.  @@@@   @@@@@@@@@@@@@@@@@     @@@@
#@&  @@@@@@  &@@@  @@@@@@  @@@  &@@@@@@@@@@@@@@@@@@@@@  @@@@
#@@  ,@@@@. ,@@@@  @@@@@%  @@  ,@@@@@@@@@@@@@@@@@@@@@@  @@@@
#@@@  @@@%  @@@@@        ,@@@  #@@@@@@@@@@@@@@@@@@@@@@  @@@@
#@@@(  @@  @@@@@@  @@@@@@@@@@.  @@@@@@@@@@@@@@@@@@@@@@  @@@@
#@@@@  &* (@@@@@@  @@@@@@@@@@@  .@@@@@@@@@@@@@@@@@@@@@  @@@@
#@@@@@    @@@@@@@  @@@@@@@@@@@@,   %@@@@%,@@@@@@@@@@@@  @@@@
#@@@@@,  @@@@@@@@  @@@@@@@@@@@@@@@(     ,@@@@@@@@@@@@@  @@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
########################
# Security Groups VPC1
########################
resource "aws_security_group" "vpc1_bastion_host_sg" {
  name_prefix            = "VPC_BH_SG"
  description            = "Allow HTTP, SSH inbound traffic from my own IP"
  vpc_id                 = "${var.vpc1_id}"
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC1 Bastion Host SG"
  }
}

resource "aws_security_group" "vpc1_docker_container_sg" {
  name_prefix            = "VPC_DC_SG"
  description            = "Allow HTTP, SSH inbound traffic from Bastion Host SG ONLY"
  vpc_id                 = "${var.vpc1_id}"
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC1 Docker Container SG"
  }
}

resource "aws_security_group" "elb1" {
  name_prefix = "ELB1 SG"
  description = "ELB1 Security Group"
  vpc_id      = "${var.vpc1_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC1 ELB SG"
  }
}

################## INGRESS RULES ####################

################### BASTION HOST SECURITY GROUP RULES ###############
resource "aws_security_group_rule" "sg1_ingress-rules_http-80_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  type              = "ingress"
  description       = "HTTP into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg1_ingress-rules_https-443_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  type              = "ingress"
  description       = "HTTPS into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg1_ingress-rules_ssh-22_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  type              = "ingress"
  description       = "SSH into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg1_BH_ingress-rules_icmp" {
  security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  type              = "ingress"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  #cidr_blocks = ["0.0.0.0/0"] #Allow ALL are just for testing purposes
  description = "ICMP from IP"

  from_port = "8"
  to_port   = "0"
  protocol  = "icmp"
}

################### DOCKER CONTAINER SECURITY GROUP RULES ###############
resource "aws_security_group_rule" "sg1_ingress-rules_http-80_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc1_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTP into Docker WebServer from Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg1_ingress-rules_https-443_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc1_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTPS into Docker WebServer from Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg1_ingress-rules_ssh-22_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc1_docker_container_sg.id}"
  type              = "ingress"
  description       = "SSH into Docker Containers from an BH"

  #self = true
  source_security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg1_DC_ingress-rules_icmp" {
  security_group_id        = "${aws_security_group.vpc1_docker_container_sg.id}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  description              = "ICMP from IP"
  from_port                = "8"
  to_port                  = "0"
  protocol                 = "icmp"
}

resource "aws_security_group_rule" "sg1_ingress-rules_http-8080_docker_container_from-ELB-BH" {
  security_group_id = "${aws_security_group.vpc1_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTP from ELB into Docker WebServer Through Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

################### ELB SECURITY GROUP RULES ###############

resource "aws_security_group_rule" "sg1_ingress-rules_elb1" {
  security_group_id = "${aws_security_group.elb1.id}"
  type              = "ingress"
  description       = "ELB SG"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 22
  to_port   = 443
  protocol  = "tcp"
}

################## EGRESS RULES ####################
resource "aws_security_group_rule" "sg1_vpc1_BH_egress_rules" {
  security_group_id = "${aws_security_group.vpc1_bastion_host_sg.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg1_vpc1_DC_egress_rules" {
  security_group_id = "${aws_security_group.vpc1_docker_container_sg.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg1_elb1_egress_rules" {
  security_group_id = "${aws_security_group.elb1.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

/*
##############################
# Default Security Group Mgmt
##############################
resource "aws_default_security_group" "default1" {
  vpc_id = "${var.vpc1_id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#  ,@@@@@@@@.  @@        @@@@@@@@*        @@@@@@@@@&    /@@@
#@  @@@@@@@@  @@@  @@@@@.  @@@@   @@@@@@@@@@@@@@@@ *@@@@   @
#@&  @@@@@@  &@@@  @@@@@@  @@@  &@@@@@@@@@@@@@@@@@@@@@@@@  @
#@@  ,@@@@. ,@@@@  @@@@@%  @@  ,@@@@@@@@@@@@@@@@@@@@@@@@@  @
#@@@  @@@%  @@@@@        ,@@@  #@@@@@@@@@@@@@@@@@@@@@@@&  @@
#@@@(  @@  @@@@@@  @@@@@@@@@@.  @@@@@@@@@@@@@@@@@@@@@@   @@@
#@@@@  &* (@@@@@@  @@@@@@@@@@@  .@@@@@@@@@@@@@@@@@@@   @@@@@
#@@@@@    @@@@@@@  @@@@@@@@@@@@,   %@@@@%,@@@@@@@@  ,@@@@@@@
#@@@@@,  @@@@@@@@  @@@@@@@@@@@@@@@(     ,@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

########################
# Security Groups VPC2
########################
resource "aws_security_group" "vpc2_bastion_host_sg" {
  name_prefix            = "VPC_BH_SG"
  description            = "Allow HTTP, SSH inbound traffic from my own IP"
  vpc_id                 = "${var.vpc2_id}"
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC1 Bastion Host SG"
  }
}

resource "aws_security_group" "vpc2_docker_container_sg" {
  name_prefix            = "VPC_DC_SG"
  description            = "Allow HTTP, SSH inbound traffic from Bastion Host SG ONLY"
  vpc_id                 = "${var.vpc2_id}"
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC1 Docker Container SG"
  }
}

resource "aws_security_group" "elb2" {
  name_prefix = "ELB2 SG"
  description = "ELB2 Security Group"
  vpc_id      = "${var.vpc2_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "VPC2 ELB SG"
  }
}

################## INGRESS RULES ####################

################### BASTION HOST SECURITY GROUP RULES ###############
resource "aws_security_group_rule" "sg2_ingress-rules_http-80_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  type              = "ingress"
  description       = "HTTP into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg2_ingress-rules_https-443_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  type              = "ingress"
  description       = "HTTPS into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg2_ingress-rules_ssh-22_BH_from-IP" {
  security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  type              = "ingress"
  description       = "SSH into Bastion Host from an specific IP"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
}

resource "aws_security_group_rule" "sg2_BH_ingress-rules_icmp" {
  security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  type              = "ingress"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  #cidr_blocks = ["0.0.0.0/0"]
  description = "ICMP from IP"

  from_port = "8"
  to_port   = "0"
  protocol  = "icmp"
}

################### DOCKER CONTAINER SECURITY GROUP RULES ###############
resource "aws_security_group_rule" "sg2_ingress-rules_http-80_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc2_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTP into Docker WebServer from Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg2_ingress-rules_https-443_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc2_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTPS into Docker WebServer from Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg2_ingress-rules_ssh-22_DC_from-BH" {
  security_group_id = "${aws_security_group.vpc2_docker_container_sg.id}"
  type              = "ingress"
  description       = "SSH into Docker Containers from an BH"

  #self = true
  source_security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "sg2_DC_ingress-rules_icmp" {
  security_group_id        = "${aws_security_group.vpc2_docker_container_sg.id}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  description              = "ICMP from IP"
  from_port                = "8"
  to_port                  = "0"
  protocol                 = "icmp"
}

resource "aws_security_group_rule" "sg2_ingress-rules_http-8080_docker_container_from-ELB-BH" {
  security_group_id = "${aws_security_group.vpc2_docker_container_sg.id}"
  type              = "ingress"
  description       = "HTTP from ELB into Docker WebServer Through Bastion Host SG"

  #self = true
  source_security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

################### ELB SECURITY GROUP RULES ###############

resource "aws_security_group_rule" "sg2_ingress-rules_elb2" {
  security_group_id = "${aws_security_group.elb2.id}"
  type              = "ingress"
  description       = "ELB SG"
  self              = true

  #cidr_blocks = ["${var.http_https_docker_container_ingress_IP}"]
  from_port = 22
  to_port   = 443
  protocol  = "tcp"
}

################## EGRESS RULES ####################
resource "aws_security_group_rule" "sg2_vpc2_BH_egress_rules" {
  security_group_id = "${aws_security_group.vpc2_bastion_host_sg.id}"
  type              = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg2_vpc2_DC_egress_rules" {
  security_group_id = "${aws_security_group.vpc2_docker_container_sg.id}"
  type              = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg2_elb2_egress_rules" {
  security_group_id = "${aws_security_group.elb2.id}"
  type              = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

/*
##############################
# Default Security Group Mgmt
##############################
resource "aws_default_security_group" "default2" {
  vpc_id = "${var.vpc2_id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

