/* terraform module
 * aws : network : route_for_igw
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating routes to your internet gateway.
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

variable "igw_id" {
  description = "VPC's internet gateway ID."
  type        = "string"
}

variable "route_dest_cidr" {
  description = "Route destination CIDR block."
  type        = "string"
  default     = "0.0.0.0/0"
}

resource "aws_route" "igw" {
  count                  = "${var.count}"
  // count                  = "${length(var.route_table_ids)}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.route_dest_cidr}"
  gateway_id             = "${var.igw_id}"
}
