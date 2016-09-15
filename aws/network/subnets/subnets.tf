/* terraform module
 * aws : network : subnets
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating vpc subnets.
 */
variable "envname" {
  description = "Environment name (e.g. Prod, Staging, EngProd)."
  type        = "string"
}

variable "envid" {
  description = "Environment id (e.g. prd, stg, eprd)."
  type        = "string"
}

variable "name" {
  description = "Name identifier (e.g. foo-public, bar-private)."
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "cidrs" {
  description = "List of CIDR blocks."
  type        = "list"
}

variable "azs" {
  description = "List of availibility zones."
  type        = "list"
}

variable "rtb_ids" {
  description = "List of route table IDs."
  type        = "list"
}

variable "info" {
  description = "Map of general support information."
  type        = "map"

  default = {
    managed_by_short = "terraform"
    managed_by_long  = "Managed by Terraform."
    src_repo_url     = "https://github.com/burdara/terraform_modules"
  }
}

resource "aws_subnet" "subnet" {
  count             = "${length(compact(var.cidrs))}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.cidrs, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name        = "${var.envid}.${var.name}.${element(var.azs, count.index)}"
    Environment = "${var.envname}"
    Role        = "networking"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

resource "aws_route_table_association" "subnet" {
  count          = "${length(compact(var.cidrs))}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${element(var.rtb_ids, count.index)}"
}

/* desciption = "List of subnet IDs."
 * type       = "list"
 */
output "ids" {
  value = ["${aws_subnet.subnet.*.id}"]
}

/* desciption = "List of subnet CIDR blocks."
 * type       = "list"
 */
output "cidrs" {
  value = ["${aws_subnet.subnet.*.cidr_block}"]
}

/* desciption = "List of subnet availability zones."
 * type       = "list"
 */
output "azs" {
  value = ["${aws_subnet.subnet.*.availability_zone}"]
}
