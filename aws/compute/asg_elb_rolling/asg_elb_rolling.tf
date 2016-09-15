/* terraform module
 * aws : apps: asg_elb_rolling
 * Author: Robbie Burda (https://github.com/burdara)
 *
 * rolling* autoscale group with elastic load balancer (asg w/ elb)
 *
 * IMPORTANT:
 *   This is an attempt to provide functionality similar to Cloudformation's
 *   rolling update for ASGs using purely terraform.
 *
 *   Based on "https://robmorgan.id.au/posts/rolling-deploys-on-aws-using-terraform"
 *
 *   This is heavily dependent on ELB's health check, so it's beneficial to have
 *   a good health check rather than a simple "protocol:port" check.
 *
 *   Launch config name is added to ASG name to cause this ASG to be replaced.
 *   lifecycle.create_before_destroy allows the prior ASG to exist as the
 *   new one is being created.
 *
 *   wait_for_elb_capacity will guarantee that new instances are up prior to
 *   destroying prior ASG.
 *
 *   if new instances do not come up with timeframe (10m), terraform will taint
 *   new ASG and leave prior ASG running.
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
  name                      = "${var.envname}-${var.stack}-${var.name}-${lc_name}"
  launch_configuration      = "${var.lc_name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  load_balancers            = ["${var.elb_names}"]
  min_size                  = "${var.min_num}"
  max_size                  = "${var.max_num}"
  wait_for_elb_capacity     = "${var.min_num}"
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
    value               = "${var.info.managed_by_short}"
    propagate_at_launch = true
  }

  tag {
    key                 = "SrcRepo"
    value               = "${var.info.src_repo_url}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
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
