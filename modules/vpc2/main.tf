terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

locals {
  max_subnet_length = "${max(length(var.vpc2_private_subnets))}"

  # max_subnet_length = "${max(length(var.vpc2_private_subnets), length(var.vpc2_elasticache_subnets), length(var.vpc2_database_subnets), length(var.vpc2_redshift_subnets))}"
  nat_gateway_count = "${var.vpc2_single_nat_gateway ? 1 : (var.vpc2_one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = "${var.vpc2_create_vpc ? 1 : 0}"

  cidr_block                       = "${var.vpc2_cidr}"
  instance_tenancy                 = "${var.vpc2_instance_tenancy}"
  enable_dns_hostnames             = "${var.vpc2_enable_dns_hostnames}"
  enable_dns_support               = "${var.vpc2_enable_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.vpc2_assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_tags, var.vpc2_tags)}"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_secondary_cidr_blocks) > 0 ? length(var.vpc2_secondary_cidr_blocks) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  cidr_block = "${element(var.vpc2_secondary_cidr_blocks, count.index)}"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.vpc2_dhcp_options_domain_name}"
  domain_name_servers  = ["${var.vpc2_dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.vpc2_dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.vpc2_dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.vpc2_dhcp_options_netbios_node_type}"

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_dhcp_options_tags, var.vpc2_tags)}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${local.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_igw_tags, var.vpc2_tags)}"
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-public", var.vpc2_name)), var.vpc2_public_route_table_tags, var.vpc2_tags)}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are so many routing tables as the largest amount of subnets of each type (really?)
#################
resource "aws_route_table" "private" {
  count = "${var.vpc2_create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.vpc2_single_nat_gateway ? "${var.vpc2_name}-private" : format("%s-private-%s", var.vpc2_name, element(var.azs, count.index)))), var.vpc2_private_route_table_tags, var.vpc2_tags)}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

/*
#################
# Database routes
#################
resource "aws_route_table" "database" {
  count = "${var.vpc2_create_vpc && var.vpc2_create_database_subnet_route_table && length(var.vpc2_database_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.vpc2_tags, var.vpc2_database_route_table_tags, map("Name", "${var.vpc2_name}-database"))}"
}

#################
# Redshift routes
#################
resource "aws_route_table" "redshift" {
  count = "${var.vpc2_create_vpc && var.vpc2_create_redshift_subnet_route_table && length(var.vpc2_redshift_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.vpc2_tags, var.vpc2_redshift_route_table_tags, map("Name", "${var.vpc2_name}-redshift"))}"
}


#################
# Elasticache routes
#################
resource "aws_route_table" "elasticache" {
  count = "${var.vpc2_create_vpc && var.vpc2_create_elasticache_subnet_route_table && length(var.vpc2_elasticache_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.vpc2_tags, var.vpc2_elasticache_route_table_tags, map("Name", "${var.vpc2_name}-elasticache"))}"
}
*/
#################
# Intra routes
#################
resource "aws_route_table" "intra" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_intra_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", "${var.vpc2_name}-intra"), var.vpc2_intra_route_table_tags, var.vpc2_tags)}"
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_public_subnets) > 0 && (!var.vpc2_one_nat_gateway_per_az || length(var.vpc2_public_subnets) >= length(var.azs)) ? length(var.vpc2_public_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${var.vpc2_public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.vpc2_map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-public-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_public_subnet_tags, var.vpc2_tags)}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_private_subnets) > 0 ? length(var.vpc2_private_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.vpc2_private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-private-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_private_subnet_tags, var.vpc2_tags)}"
}

/*
##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_database_subnets) > 0 ? length(var.vpc2_database_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.vpc2_database_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-db-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_database_subnet_tags, var.vpc2_tags)}"
}

resource "aws_db_subnet_group" "database" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_database_subnets) > 0 && var.vpc2_create_database_subnet_group ? 1 : 0}"

  name        = "${lower(var.vpc2_name)}"
  description = "Database subnet group for ${var.vpc2_name}"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_database_subnet_group_tags, var.vpc2_tags)}"
}

##################
# Redshift subnet
##################
resource "aws_subnet" "redshift" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_redshift_subnets) > 0 ? length(var.vpc2_redshift_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.vpc2_redshift_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-redshift-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_redshift_subnet_tags, var.vpc2_tags)}"
}

resource "aws_redshift_subnet_group" "redshift" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_redshift_subnets) > 0 ? 1 : 0}"

  name        = "${var.vpc2_name}"
  description = "Redshift subnet group for ${var.vpc2_name}"
  subnet_ids  = ["${aws_subnet.redshift.*.id}"]

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_redshift_subnet_group_tags, var.vpc2_tags)}"
}


#####################
# ElastiCache subnet
#####################
resource "aws_subnet" "elasticache" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_elasticache_subnets) > 0 ? length(var.vpc2_elasticache_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.vpc2_elasticache_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-elasticache-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_elasticache_subnet_tags, var.vpc2_tags)}"
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_elasticache_subnets) > 0 ? 1 : 0}"

  name        = "${var.vpc2_name}"
  description = "ElastiCache subnet group for ${var.vpc2_name}"
  subnet_ids  = ["${aws_subnet.elasticache.*.id}"]
}
*/
#####################################################
# intra subnets - private subnet without NAT gateway
#####################################################
resource "aws_subnet" "intra" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_intra_subnets) > 0 ? length(var.vpc2_intra_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.vpc2_intra_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-intra-%s", var.vpc2_name, element(var.azs, count.index))), var.vpc2_intra_subnet_tags, var.vpc2_tags)}"
}

##############
# NAT Gateway
##############
# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.vpc2_reuse_nat_ips ? var.vpc2_external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = "${split(",", (var.vpc2_reuse_nat_ips ? join(",", var.vpc2_external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${var.vpc2_create_vpc && (var.vpc2_enable_nat_gateway && !var.vpc2_reuse_nat_ips) ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(map("Name", format("%s-%s", var.vpc2_name, element(var.azs, (var.vpc2_single_nat_gateway ? 0 : count.index)))), var.vpc2_nat_eip_tags, var.vpc2_tags)}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.vpc2_single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.vpc2_single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-%s", var.vpc2_name, element(var.azs, (var.vpc2_single_nat_gateway ? 0 : count.index)))), var.vpc2_nat_gateway_tags, var.vpc2_tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

/*
######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_s3_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_s3_endpoint && length(var.vpc2_intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_s3_endpoint && length(var.vpc2_public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

############################
# VPC Endpoint for DynamoDB
############################
data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dynamodb_endpoint ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dynamodb_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dynamodb_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dynamodb_endpoint && length(var.vpc2_intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_dynamodb_endpoint && length(var.vpc2_public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.public.id}"
}
*/
##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_private_subnets) > 0 ? length(var.vpc2_private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, (var.vpc2_single_nat_gateway ? 0 : count.index))}"
}

/*
resource "aws_route_table_association" "database" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_database_subnets) > 0 ? length(var.vpc2_database_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.database.*.id, aws_route_table.private.*.id), (var.vpc2_single_nat_gateway || var.vpc2_create_database_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "redshift" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_redshift_subnets) > 0 ? length(var.vpc2_redshift_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.redshift.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.redshift.*.id, aws_route_table.private.*.id), (var.vpc2_single_nat_gateway || var.vpc2_create_redshift_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "elasticache" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_elasticache_subnets) > 0 ? length(var.vpc2_elasticache_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.elasticache.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.elasticache.*.id, aws_route_table.private.*.id), (var.vpc2_single_nat_gateway || var.vpc2_create_elasticache_subnet_route_table ? 0 : count.index))}"
}
*/
resource "aws_route_table_association" "intra" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_intra_subnets) > 0 ? length(var.vpc2_intra_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.intra.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.intra.*.id, 0)}"
}

resource "aws_route_table_association" "public" {
  count = "${var.vpc2_create_vpc && length(var.vpc2_public_subnets) > 0 ? length(var.vpc2_public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

/*
##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = "${var.vpc2_create_vpc && var.vpc2_enable_vpn_gateway ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.vpc2_name)), var.vpc2_vpn_gateway_tags, var.vpc2_tags)}"
}

resource "aws_vpn_gateway_attachment" "this" {
  count = "${var.vpc2_vpn_gateway_id != "" ? 1 : 0}"

  vpc_id         = "${local.vpc_id}"
  vpn_gateway_id = "${var.vpc2_vpn_gateway_id}"
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = "${var.vpc2_create_vpc && var.vpc2_propagate_public_route_tables_vgw && (var.vpc2_enable_vpn_gateway || var.vpc2_vpn_gateway_id != "") ? 1 : 0}"

  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = "${var.vpc2_create_vpc && var.vpc2_propagate_private_route_tables_vgw && (var.vpc2_enable_vpn_gateway || var.vpc2_vpn_gateway_id != "") ? length(var.vpc2_private_subnets) : 0}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}
*/
###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = "${var.manage_default_vpc2 ? 1 : 0}"

  enable_dns_support   = "${var.default_vpc2_enable_dns_support}"
  enable_dns_hostnames = "${var.default_vpc2_enable_dns_hostnames}"
  enable_classiclink   = "${var.default_vpc2_enable_classiclink}"

  tags = "${merge(map("Name", format("%s", var.default_vpc2_name)), var.default_vpc2_tags, var.vpc2_tags)}"
}

#################
# Load Balancer
#################
resource "aws_elb" "tc-elb2" {
  name            = "TC-ELB2"
  security_groups = ["${var.vpc2_elb_sg_id}"]
  subnets         = ["${aws_subnet.public.*.id}"]
  internal        = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8080"
    instance_protocol = "http"
  }
}
