output "deployment_group_arn" {
  value       = aws_codedeploy_deployment_group.this.arn
  description = "ARN of a CodeDeploy deployment group"
}

output "deployment_group_name" {
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
  description = "A name of a CodeDeploy deployment group"
}

output "codedeploy_application_name" {
  value       = aws_codedeploy_app.this.name
  description = "CodeDeploy application name"
}
