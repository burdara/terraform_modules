/* terraform module
 * aws : network : public_route_tables_igw
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creates public route tables with internet gateway (igw)
 */
variable "envname" {
  description = "Environment name (e.g. Prod, Staging, EngProd)."
  type        = "string"
}

variable "envid" {
  description = "Environment id (e.g. prd, stg, eprd)."
  type        = "string"
}

variable "name" {
  description = "Name identifier."
  type        = "string"
  default     = "public"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "azs" {
  description = "List of availibility zones."
  type        = "list"
}

variable "igw_id" {
  description = "VPC's internet gateway ID."
  type        = "string"
}

module "public_route_tables" {
  source  = "../route_tables"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "${var.name}"
  vpc_id  = "${var.vpc_id}"
  azs     = ["${var.azs}"]
  type    = "public"
}

module "routes_for_igw" {
  source          = "../routes_for_igw"
  route_table_ids = ["${module.public_route_tables.ids}"]
  igw_id          = "${var.igw_id}"
}

/* description = "List of public route tables IDs"
 * type        = "list"
 */
output "ids" {
  value = ["${module.public_route_tables.ids}"]
}
