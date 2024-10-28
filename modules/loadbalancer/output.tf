output "target_group_name" {
  value       = aws_lb_target_group.app.name
  description = "A target group name of a load balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "A target group arn of a load balancer"
}

output "backend_redis_target_group_name" {
  value       = aws_lb_target_group.backend_redis_app.name
  description = "backend_redis target group name of a load balancer"
}

output "backend_redis_target_group_arn" {
  value       = aws_lb_target_group.backend_redis_app.arn
  description = "backend_redis target group arn of a load balancer"
}
