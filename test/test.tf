variable "envname" {
  type    = "string"
  default = "test"
}

variable "envid" {
  type    = "string"
  default = "test"
}

variable "acct" {
  type    = "string"
  default = "123456789"
}

variable "azs" {
  type    = "list"
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_cidrs" {
  type    = "list"
  default = ["10.0.0.0/24", "10.0.0.1/24", "10.0.0.2/24"]
}

variable "private_cidrs" {
  type    = "list"
  default = ["10.0.0.3/24", "10.0.0.4/24", "10.0.0.5/24"]
}

module "test_vpc" {
  source  = "../aws/network/vpc"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test"
  cidr    = "10.0.0.0/16"
}

module "test_vpc2" {
  source  = "../aws/network/vpc"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test"
  cidr    = "10.1.0.0/16"
}

module "test_peering" {
  source        = "../aws/network/peering_connection"
  vpc_id        = "${module.test_vpc.id}"
  peer_vpc_id   = "${module.test_vpc2.id}"
  peer_owner_id = "${var.acct}"
}

module "test_public_rt" {
  source  = "../aws/network/route_tables"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test-public"
  vpc_id  = "${module.test_vpc.id}"
  azs     = ["${var.azs}"]
  type    = "public"
}

module "test_private_rt" {
  source  = "../aws/network/route_tables"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test-private"
  vpc_id  = "${module.test_vpc.id}"
  azs     = ["${var.azs}"]
  type    = "private"
}

module "test_routes_for_igw" {
  source          = "../aws/network/routes_for_igw"
  count           = "${length(var.azs)}"
  route_table_ids = ["${module.test_public_rt.ids}"]
  igw_id          = "${module.test_vpc.igw_id}"
}

module "test_public_subnets" {
  source  = "../aws/network/subnets"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test-public"
  vpc_id  = "${module.test_vpc.id}"
  cidrs   = ["${var.public_cidrs}"]
  azs     = ["${var.azs}"]
  rtb_ids = ["${module.test_public_rt.ids}"]
}

module "test_nats" {
  source     = "../aws/network/nat_gateways"
  count      = "${length(var.azs)}"
  subnet_ids = ["${module.test_public_subnets.ids}"]
}

module "test_routes_for_nats" {
  source          = "../aws/network/routes_for_nats"
  count           = "${length(var.azs)}"
  route_table_ids = ["${module.test_private_rt.ids}"]
  natgw_ids       = ["${module.test_nats.ids}"]
}

module "test_routes_for_pcx" {
  source          = "../aws/network/routes_for_pcx"
  count           = "${length(var.azs)}"
  route_table_ids = ["${module.test_public_rt.ids}"]
  route_dest_cidr = "${module.test_vpc.cidr}"
  pcx_id          = "${module.test_peering.id}"
}

module "test_routes_for_pcx1" {
  source          = "../aws/network/routes_for_pcx"
  count           = "${length(var.azs)}"
  route_table_ids = ["${module.test_private_rt.ids}"]
  route_dest_cidr = "${module.test_vpc2.cidr}"
  pcx_id          = "${module.test_peering.id}"
}

module "test_private_subnets" {
  source  = "../aws/network/subnets"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "test-private"
  vpc_id  = "${module.test_vpc.id}"
  cidrs   = ["${var.private_cidrs}"]
  azs     = ["${var.azs}"]
  rtb_ids = ["${module.test_private_rt.ids}"]
}
