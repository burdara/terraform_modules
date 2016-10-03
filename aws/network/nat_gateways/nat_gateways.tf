/* terraform module
 * aws : network : nat_gateways
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating NAT gateways.
 */

/* TODO(robbieb): adding this due to terraform bug
 * using subnet_ids list to calculate count causes a graph cycle currently.
 * Related issues:
 *   https://github.com/hashicorp/terraform/issues/2301
 */
variable "count" {
  description = "Number of NAT gateways to create."
  type        = "string"
}

variable "subnet_ids" {
  description = "List of NAT Gateway subnet IDs."
  type        = "list"
  default     = []
}

resource "aws_eip" "nat" {
  count = "${var.count}"
  // count = "${length(var.subnet_ids)}"
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count         = "${var.count}"
  // count         = "${length(var.subnet_ids)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(var.subnet_ids, count.index)}"
}

/* description = "List of NAT gateway IDs."
 * type        = "list"
 */
output "ids" {
  value = ["${aws_nat_gateway.nat.*.id}"]
}
