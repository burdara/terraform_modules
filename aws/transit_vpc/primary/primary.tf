/* terraform module
 * aws : transit_vpc : primary
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * Module creates primary transit vpc using AWS's cloudformation template.
 *
 * (SO0001) - Transit VPC: This template creates a dedicated transit VPC with
 * Cisco CSRs for routing traffic.
 * ***NOTE*** You must first subscribe to the appropriate Cisco CSR marketplace
 * BYOL or License Included AMI from the AWS Marketplace before you launch this
 * template.
 * Version 2
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
  default     = "https://s3.amazonaws.com/solutions-reference/transit-vpc/latest/transit-vpc-primary-account.template"
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances"
  type        = "string"
  default     = "Lab"
}

variable "spoke_tag" {
  description = "Tag to use to identify spoke VPCs to connect to Transit VPC."
  type        = "string"
  default     = "transitvpc:spoke"
}

variable "spoke_tag_value" {
  description = "Tag value to use to identify spoke VPCs to connect to Transit VPC."
  type        = "string"
  default     = "true"
}

variable "bgp_asn" {
  description = "BGP ASN to use for Transit VPC."
  type        = "string"
  default     = "64512"
}

variable "vpc_cidr" {
  description = "CIDR block for Transit VPC."
  type        = "string"
  default     = "100.64.127.224/27"
}

variable "pub_subnet1" {
  description = "Address range for Transit VPC subnet to be created in AZ1."
  type        = "string"
  default     = "100.64.127.224/28"
}

variable "pub_subnet2" {
  description = "Address range for Transit VPC subnet to be created in AZ2."
  type        = "string"
  default     = "100.64.127.240/28"
}

# AllowedValues: [ "2x500Mbps","2x1Gbps", "2x2Gbps" ]
variable "csr_type" {
  description = "Maximum network througput required for CSR instances."
  type        = "string"
  default     = "2x500Mbps"
}

# AllowedValues: [ "LicenseIncluded", "BYOL" ]
variable "license_model" {
  description = "Choose between BYOL (Bring Your Own License) and License Included license models. Remember to first subscribe the the appropriate Marketplace AMI!"
  type        = "string"
  default     = "LicenseIncluded"
}

variable "s3_prefix" {
  description = "S3 prefix to append before S3 key names."
  type        = "string"
  default     = "vpnconfigs/"
}

variable "account_id" {
  description = "Another AWS Account ID to authorize access to VPN Config S3 bucket (for example bucket and KMS key policies)."
  type        = "string"
  default     = ""
}

# AllowedValues: [ "Yes", "No" ]
variable "send_anonymous_data" {
  description = "Choose to send anonymous data to AWS."
  type        = "string"
  default     = "Yes"
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

resource "aws_cloudformation_stack" "primary" {
  name         = "${var.envid}-transit-vpc-primary"
  template_url = "${var.template_url}"

  parameters {
    KeyName           = "${var.key_name}"
    SpokeTag          = "${var.spoke_tag}"
    SpokeTagValue     = "${var.spoke_tag_value}"
    BgpAsn            = "${var.bgp_asn}"
    VpcCidr           = "${var.vpc_cidr}"
    PubSubnet1        = "${var.pub_subnet1}"
    PubSubnet2        = "${var.pub_subnet2}"
    CSRType           = "${var.csr_type}"
    LicenseModel      = "${var.license_model}"
    S3Prefix          = "${var.s3_prefix}"
    AccountId         = "${var.account_id}"
    SendAnonymousData = "${var.send_anonymous_data}"
  }

  tags {
    Name        = "${var.envid}-transit-vpc-primary"
    Environment = "${var.envname}"
    Role        = "stack"
    App         = "transit-vpc-primary"
    ManagedBy   = "${var.info.managed_by_short}"
    SrcRepo     = "${var.info.src_repo_url}"
  }
}

/* desciption = "IP Address for CSR1"
 * type       = "string"
 */
output "csr1" {
  value = "${aws_cloudformation_stack.primary.outputs.CSR1}"
}

/* desciption = "IP Address for CSR2"
 * type       = "string"
 */
output "csr2" {
  value = "${aws_cloudformation_stack.primary.outputs.CSR2}"
}

/* desciption = "S3 bucket for storing VPN configuration information."
 * type       = "string"
 */
output "config_s3_bucket" {
  value = "${aws_cloudformation_stack.primary.outputs.ConfigS3Bucket}"
}

/* desciption = "S3 prefix for storing VPN configuration information."
 * type       = "string"
 */
output "bucket_prefix" {
  value = "${aws_cloudformation_stack.primary.outputs.BucketPrefix}"
}

/* desciption = "Tag used to identify spoke VPCs."
 * type       = "string"
 */
output "spoke_vpc_tag" {
  value = "${aws_cloudformation_stack.primary.outputs.SpokeVPCTag}"
}

/* desciption = "Tag valued used to idenfity spoke VPCs."
 * type       = "string"
 */
output "spoke_vpc_tag_value" {
  value = "${aws_cloudformation_stack.primary.outputs.SpokeVPCTagValue}"
}
