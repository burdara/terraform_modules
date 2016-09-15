/* terraform module
 * aws : network : private_route_tables_nats
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creates private route tables with NAT gateways.
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

variable "natgw_ids" {
  description = "List of NAT Gateway IDs."
  type        = "list"
}

module "private_route_tables" {
  source  = "../route_tables"
  envname = "${var.envname}"
  envid   = "${var.envid}"
  name    = "${var.name}"
  vpc_id  = "${var.vpc_id}"
  azs     = ["${var.azs}"]
  type    = "private"
}

module "routes_for_nats" {
  source          = "../routes_for_nats"
  route_table_ids = ["${module.private_route_tables.ids}"]
  natgw_ids       = ["${var.natgw_ids}"]
}

/* description = "List of private route tables IDs"
 * type        = "list"
 */
output "ids" {
  value = ["${module.private_route_tables.ids}"]
}
