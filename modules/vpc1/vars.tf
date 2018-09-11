variable "vpc1_create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default     = true
}

variable "vpc1_name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "vpc1_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "vpc1_assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block"
  default     = false
}

variable "vpc1_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  default     = []
}

variable "vpc1_instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "vpc1_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "vpc1_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

/*
variable "database_subnets" {
  type        = "list"
  description = "A list of database subnets"
  default     = []
}

variable "redshift_subnets" {
  type        = "list"
  description = "A list of redshift subnets"
  default     = []
}

variable "elasticache_subnets" {
  type        = "list"
  description = "A list of elasticache subnets"
  default     = []
}

variable "vpc1_create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  default     = false
}

variable "vpc1_create_redshift_subnet_route_table" {
  description = "Controls if separate route table for redshift should be created"
  default     = false
}

variable "vpc1_create_elasticache_subnet_route_table" {
  description = "Controls if separate route table for elasticache should be created"
  default     = false
}
*/
variable "vpc1_intra_subnets" {
  type        = "list"
  description = "A list of intra subnets"
  default     = []
}

/*
variable "vpc1_create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  default     = true
}
*/
variable "azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "vpc1_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = false
}

variable "vpc1_enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "vpc1_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "vpc1_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "vpc1_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}

variable "vpc1_reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  default     = false
}

variable "vpc1_external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = "list"
  default     = []
}

/*
variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = false
}

variable "vpc1_enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
}
*/
variable "vpc1_map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "vpc1_enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "vpc1_vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  default     = ""
}

variable "vpc1_propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}

variable "vpc1_propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  default     = false
}

variable "vpc1_tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc1_vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "vpc1_igw_tags" {
  description = "Additional tags for the internet gateway"
  default     = {}
}

variable "vpc1_public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "vpc1_private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {}
}

variable "vpc1_public_route_table_tags" {
  description = "Additional tags for the public route tables"
  default     = {}
}

variable "vpc1_private_route_table_tags" {
  description = "Additional tags for the private route tables"
  default     = {}
}

/*
variable "database_route_table_tags" {
  description = "Additional tags for the database route tables"
  default     = {}
}

variable "redshift_route_table_tags" {
  description = "Additional tags for the redshift route tables"
  default     = {}
}

variable "elasticache_route_table_tags" {
  description = "Additional tags for the elasticache route tables"
  default     = {}
}
*/
variable "vpc1_intra_route_table_tags" {
  description = "Additional tags for the intra route tables"
  default     = {}
}

/*
variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  default     = {}
}

variable "database_subnet_group_tags" {
  description = "Additional tags for the database subnet group"
  default     = {}
}

variable "redshift_subnet_tags" {
  description = "Additional tags for the redshift subnets"
  default     = {}
}

variable "redshift_subnet_group_tags" {
  description = "Additional tags for the redshift subnet group"
  default     = {}
}

variable "elasticache_subnet_tags" {
  description = "Additional tags for the elasticache subnets"
  default     = {}
}
*/
variable "vpc1_intra_subnet_tags" {
  description = "Additional tags for the intra subnets"
  default     = {}
}

variable "vpc1_dhcp_options_tags" {
  description = "Additional tags for the DHCP option set"
  default     = {}
}

variable "vpc1_nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  default     = {}
}

variable "vpc1_nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  default     = {}
}

variable "vpc1_vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  default     = {}
}

variable "vpc1_enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  default     = false
}

variable "vpc1_dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = ""
}

variable "vpc1_dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = "list"
  default     = ["AmazonProvidedDNS"]
}

variable "vpc1_dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "vpc1_dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "vpc1_dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}

variable "manage_default_vpc1" {
  description = "Should be true to adopt and manage Default VPC"
  default     = false
}

variable "default_vpc1_name" {
  description = "Name to be used on the Default VPC"
  default     = ""
}

variable "default_vpc1_enable_dns_support" {
  description = "Should be true to enable DNS support in the Default VPC"
  default     = true
}

variable "default_vpc1_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  default     = false
}

variable "default_vpc1_enable_classiclink" {
  description = "Should be true to enable ClassicLink in the Default VPC"
  default     = false
}

variable "default_vpc1_tags" {
  description = "Additional tags for the Default VPC"
  default     = {}
}

variable "vpc1_elb_sg_id" {}
