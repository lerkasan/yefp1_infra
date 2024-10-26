output "iam_role_arn" {
  value       = aws_iam_role.appserver_iam_role.arn
  description = "IAM role ARN of the EC2 instances"
}

output "name" {
  value       = aws_autoscaling_group.appserver.name
  description = "Name of the autoscaling group"
}
