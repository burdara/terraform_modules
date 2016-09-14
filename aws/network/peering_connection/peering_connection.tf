/* terraform module
 * aws : network : peering_connection
 * Author: Robbie Burda
 *
 * Module for creating peering connection
 */
variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "peer_vpc_id" {
  description = "Peering VPC ID."
  type        = "string"
}

variable "peer_owner_id" {
  description = "Peering owner ID."
  type        = "string"
}

resource "aws_vpc_peering_connection" "peering" {
  vpc_id        = "${var.vpc_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  peer_owner_id = "${var.peer_owner_id}"
}

/* description = "Peering connection ID."
 * type        = "string"
 */
output "id" {
  value = "${aws_vpc_peering_connection.peering.id}"
}
