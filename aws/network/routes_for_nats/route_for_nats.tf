/* terraform module
 * aws : network : routes_for_nats
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating routes for your NAT gateways.
 */
variable "route_table_ids" {
  description = "List of route table ids."
  type        = "list"
}

variable "natgw_ids" {
  description = "List of NAT gateway ids."
  type        = "list"
}

variable "route_dest_cidr" {
  description = "Route destination CIDR block."
  type        = "string"
  default     = "0.0.0.0/0"
}

resource "aws_route" "nat" {
  count                  = "${length(compact(var.route_table_ids))}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.route_dest_cidr}"
  nat_gateway_id         = "${element(var.natgw_ids, count.index)}"
}
