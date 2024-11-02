resource "aws_autoscaling_group" "appserver" {
  name                      = join("_", [var.project_name, "_autoscaling_group"])
  max_size                  = var.autoscale_max_size
  min_size                  = var.autoscale_min_size
  desired_capacity          = var.autoscale_desired_capacity
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  target_group_arns         = var.alb_target_group_arns
  vpc_zone_identifier       = var.private_subnets_ids

#  default_instance_warmup     = 300

  launch_template {
    id      = aws_launch_template.appserver.id
    version = "$Latest"
  }

  timeouts {
    delete = var.autoscale_delete_timeout
  }

  tag {
    key                 = "Name"
    value               = join("_", [var.project_name, "_appserver_autoscaling"])
    propagate_at_launch = true
  }

  tag {
    key                 = "terraform"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "appserver" {
  name                        = join("_", [var.project_name, "_appserver"])

  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  user_data                   = data.cloudinit_config.user_data.rendered
  key_name                    = var.appserver_private_ssh_key_name
  vpc_security_group_ids      = [ var.ec2_sg_id ]

  monitoring {
    enabled = var.monitoring_enabled
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_type           = var.ebs_volume_type
      volume_size           = var.ebs_volume_size
    }
  }

  tags = {
      Name        = join("_", [var.project_name, "_appserver"])
      terraform   = "true"
      environment = var.environment
      project     = var.project_name
    }
}

resource "aws_autoscaling_policy" "avg_cpu_utilization" {
  name    = join("_", [var.project_name, "_appserver_autoscaling_policy"])
  autoscaling_group_name = aws_autoscaling_group.appserver.name
  adjustment_type        = "ChangeInCapacity"
  policy_type = "TargetTrackingScaling"
#   cooldown = 300
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id             = var.private_subnets_ids[0]
  security_group_ids    = [ var.ec2_connect_endpoint_sg_id ]
  preserve_client_ip    = true

  tags = {
    Name        = join("_", [var.project_name, "ec2_connect_endpoint"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  for_each      = toset(var.log_group_names)

  name          = join("_", [var.project_name, var.log_group_names[index(var.log_group_names, each.value)]])

  tags          = {
    Name        = join("_", [var.project_name, "_log_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}
