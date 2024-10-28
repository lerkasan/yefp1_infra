resource "aws_codedeploy_app" "this" {
  name = var.project_name

  tags = {
    Name        = join("_", [var.project_name, "_appserver"])
    terraform   = "true"
    project     = var.project_name
  }
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name                = aws_codedeploy_app.this.name
  deployment_group_name   = var.deployment_group_name
  autoscaling_groups      = [var.autoscaling_group_name]
  service_role_arn        = aws_iam_role.codedeploy.arn
  deployment_config_name  = var.deployment_config_name

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   =  var.deployment_type
  }

  load_balancer_info {
    target_group_info {
      name = var.target_group_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

#   ec2_tag_set {
#     ec2_tag_filter {
#       key   = "Name"
#       type  = "KEY_AND_VALUE"
#       value = join("_", [var.project_name, "_appserver_autoscaling"])
#     }

#     ec2_tag_filter {
#       key   = "project"
#       type  = "KEY_AND_VALUE"
#       value = var.project_name
#     }
#   }

  tags = {
    Name        = join("_", [var.project_name, "_appserver"])
    terraform   = "true"
    project     = var.project_name
  }
}