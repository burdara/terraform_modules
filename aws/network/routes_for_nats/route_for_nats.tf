/* terraform module
 * aws : network : routes_for_nats
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating routes for your NAT gateways.
 */

/* TODO(robbieb): adding this due to terraform bug
 * using subnet_ids list to calculate count causes a graph cycle currently.
 * Related issues:
 *   https://github.com/hashicorp/terraform/issues/2301
 */
variable "count" {
  description = "Number of route tables to assign routes."
  type        = "string"
}

variable "route_table_ids" {
  description = "List of route table ids."
  type        = "list"
  default     = []
}

variable "natgw_ids" {
  description = "List of NAT gateway ids."
  type        = "list"
  default     = []
}

variable "route_dest_cidr" {
  description = "Route destination CIDR block."
  type        = "string"
  default     = "0.0.0.0/0"
}

resource "aws_route" "nat" {
  count                  = "${var.count}"
  // count                  = "${length(var.route_table_ids)}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.route_dest_cidr}"
  nat_gateway_id         = "${element(var.natgw_ids, count.index)}"
}
