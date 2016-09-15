/* terraform module
 * aws : network : nat_gateways
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating NAT gateways.
 */
variable "subnet_ids" {
  description = "List of NAT Gateway subnet IDs."
  type        = "list"
}

resource "aws_eip" "nat" {
  count = "${length(compact(var.subnet_ids))}"
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count         = "${length(compact(var.subnet_ids))}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(var.subnet_ids, count.index)}"
}

/* description = "List of NAT gateway IDs."
 * type        = "list"
 */
output "ids" {
  value = ["${aws_nat_gateway.nat.*.id}"]
}
