/* terraform module
 * aws : apps : asg_elb
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * autoscale group with elastic load balancer (asg w/ elb)
 */
variable "envname" {
  description = "Environment name (e.g. Prod, Staging, EngProd)."
  type        = "string"
}

variable "envid" {
  description = "Environment id (e.g. prd, stg, eprd)."
  type        = "string"
}

variable "stack" {
  description = "Stack identifier."
  type        = "string"
}

variable "name" {
  description = "Name Identifier."
  type        = "string"
}

variable "lc_name" {
  description = "Launch configuration name."
  type        = "string"
}

variable "subnet_ids" {
  description = "List of Subnet IDs."
  type        = "list"
}

variable "min_num" {
  description = "Minimum number of Nodes in ASG."
  type        = "string"
}

variable "max_num" {
  description = "Maximum number of Nodes in ASG."
  type        = "string"
}

variable "elb_names" {
  description = "List of elastic load balancer (ELB) names."
  type        = "list"
}

variable "health_check_grace_period" {
  description = "Health check grace period for ASG."
  type        = "string"
  default     = "15"
}

variable "health_check_type" {
  description = "Health check type for ASG."
  type        = "string"
  default     = "ELB"
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

resource "aws_autoscaling_group" "app" {
  name                      = "${var.envname}-${var.stack}-${var.name}"
  launch_configuration      = "${var.lc_name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  load_balancers            = ["${var.elb_names}"]
  min_size                  = "${var.min_num}"
  max_size                  = "${var.max_num}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  metrics_granularity       = "1Minute"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
  ]

  tag {
    key                 = "Name"
    value               = "${var.envid}-${var.stack}-${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.envname}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Stack"
    value               = "${var.stack}"
    propagate_at_launch = true
  }

  tag {
    key                 = "App"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "${var.info["managed_by_short"]}"
    propagate_at_launch = true
  }

  tag {
    key                 = "SrcRepo"
    value               = "${var.info["src_repo_url"]}"
    propagate_at_launch = true
  }
}

/* desciption = "Auto scaling group (ASG) ID."
 * type       = "string"
 */
output "id" {
  value = "${aws_autoscaling_group.app.id}"
}

/* desciption = "Auto scaling group (ASG) name."
 * type       = "string"
 */
output "name" {
  value = "${aws_autoscaling_group.app.name}"
}
