/* terraform module
 * aws : network : route_tables
 * Author: Robbie Burda
 *
 * Module for creating route tables
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
  description = "Name identifier."
  type        = "string"
  default     = "public"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "azs" {
  description = "List of availibility zones."
  type        = "list"
}

variable "type" {
  description = "Route table type (e.g. public, private, etc.)."
  type        = "string"
}

variable "info" {
  description = "Map of general support information."
  type        = "map"
  default     = {
    managed_by_short = "terraform"
    managed_by_long  = "Managed by Terraform."
    src_repo_url     = "https://github.com/burdara/terraform_modules"
  }
}

resource "aws_route_table" "public" {
  count  = "${length(compact(var.azs))}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.envid}.${var.name}.${element(var.azs, count.index)}"
    Environment = "${var.envname}"
    Role        = "networking"
    Type        = "${var.type}"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

/* description = "List of public route tables IDs"
 * type        = "list"
 */
output "ids" {
  value = ["${aws_route_table.public.*.id}"]
}
