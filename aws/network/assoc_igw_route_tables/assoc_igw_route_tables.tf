/* terraform module
 * aws : network : assoc_igw_route_tables
 * Author: Robbie Burda
 *
 * Module for creating a route to the vpc's internet gateway.
 */
variable "route_table_ids" {
  description = "List of route table IDs."
  type        = "list"
}

variable "igw_id" {
  description = "VPC's internet gateway ID."
  type        = "string"
}

variable "route_dest_cidr" {
  description = "Route destination CIDR block."
  type        = "list"
  default     = "0.0.0.0/0"
}

resource "aws_route" "assoc_igw" {
  count                  = "${length(compact(var.route_table_ids))}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.route_dest_cidr}"
  gateway_id             = "${var.igw_id}"
}
