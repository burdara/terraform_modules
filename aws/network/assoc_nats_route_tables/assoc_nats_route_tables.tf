/* terraform module
 * aws : network : assoc_nats_route_tables
 * Author: Robbie Burda
 *
 * Module for creating a route to the a list of NAT gateways.
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
  type        = "list"
  default     = "0.0.0.0/0"
}

resource "aws_route" "private" {
  count                  = "${length(compact(var.route_table_ids))}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.route_dest_cidr}"
  nat_gateway_id         = "${element(var.natgw_ids, count.index)}"
}
