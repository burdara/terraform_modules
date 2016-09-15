/* terraform module
 * aws : transit_vpc : secondary
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module creates secondary transit vpc using AWS's cloudformation template.
 *
 * (SO0001p) - Transit VPC: This template creates a TransitVPC poller function
 * to find spoke VPCs to add to the transit network.
 */
variable "envname" {
  description = "Environment name (e.g. Prod, Staging, EngProd)."
  type        = "string"
}

variable "envid" {
  description = "Environment id (e.g. prd, stg, eprd)."
  type        = "string"
}

variable "template_url" {
  description = "Transit VPC primary cloudformation template url."
  type        = "string"
  default     = "https://s3.amazonaws.com/solutions-reference/transit-vpc/latest/transit-vpc-second-account.template"
}

variable "bucket_name" {
  description = "Name of the bucket used to store transit VPC configuration files."
  type        = "string"
  default     = "transit-vpc"
}

variable "bucket_prefix" {
  description = "S3 object prefix for storing VPN configuration."
  type        = "string"
  default     = "vpnconfigs/"
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

resource "aws_cloudformation_stack" "secondary" {
  name         = "${var.envid}-transit-vpc-secondary"
  template_url = "${var.template_url}"

  parameters {
    BucketName   = "${var.bucket_name}"
    BucketPrefix = "${var.bucket_prefix}"
  }

  tags {
    Name        = "${var.envid}-transit-vpc-secondary"
    Environment = "${var.envname}"
    Role        = "stack"
    App         = "transit-vpc-secondary"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

/* desciption = "New Lambda function name."
  * type       = "string"
  */
output "poller_function" {
  value = "${aws_cloudformation_stack.secondary.outputs.PollerFunction}"
}

/* desciption = "ARN for new Lambda function."
  * type       = "string"
  */
output "poller_function_arn" {
  value = "${aws_cloudformation_stack.secondary.outputs.PollerFunctionARN}"
}

/* desciption = "ARN for poller function role."
  * type       = "string"
  */
output "poller_role_arn" {
  value = "${aws_cloudformation_stack.secondary.outputs.PollerRoleARN}"
}
