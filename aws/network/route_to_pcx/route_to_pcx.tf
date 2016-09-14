/* terraform module
 * aws : network : route_to_pcx
 * Author: Robbie Burda
 *
 * Module for creating a route to peering connection.
 */
variable "route_table_ids" {
  description = "List of route table IDs."
  type        = "list"
}

variable "pcx_id" {
  description = "Peering connection ID."
  type        = "string"
}

variable "route_dest_cidr" {
  description = "Route destination CIDR block."
  type        = "string"
}

resource "aws_route" "pcx" {
  count                     = "${length(compact(var.route_table_ids))}"
  route_table_id            = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block    = "${var.route_dest_cidr}"
  vpc_peering_connection_id = "${var.pcx_id}"
}
