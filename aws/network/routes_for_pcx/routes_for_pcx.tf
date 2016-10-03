/* terraform module
 * aws : network : routes_for_pcx
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating routes for peering connection.
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
  description = "List of route table IDs."
  type        = "list"
  default     = []
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
  count                     = "${var.count}"
  // count                     = "${length(var.route_table_ids)}"
  route_table_id            = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block    = "${var.route_dest_cidr}"
  vpc_peering_connection_id = "${var.pcx_id}"
}
