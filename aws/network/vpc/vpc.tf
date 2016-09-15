/* terraform module
 * aws : network : vpc
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module for creating vpc and related resoures (i.e. internet gateway)
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
  default     = "main"
}

variable "cidr" {
  description = "VPC cidr block."
  type        = "string"
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

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.envid}-${var.name}"
    Environment = "${var.envname}"
    Role        = "networking"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.envid}-${var.name}"
    Environment = "${var.envname}"
    Role        = "networking"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

/* desciption = "VPC ID."
 * type       = "string"
 */
output "id" {
  value = "${aws_vpc.vpc.id}"
}

/* desciption = "VPC's cidr block."
 * type       = "string"
 */
output "cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

/* desciption = "VPC's Internet gateway ID."
 * type       = "string"
 */
output "igw_id" {
  value = "${aws_internet_gateway.vpc.id}"
}
