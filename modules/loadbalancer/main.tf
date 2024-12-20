resource "aws_lb" "app" {
  name                             = var.lb_name
  internal                         = var.lb_internal
  load_balancer_type               = var.lb_type
  security_groups                  = [var.lb_sg_id]
  subnets                          = var.public_subnets_ids
  drop_invalid_header_fields       = true
  enable_cross_zone_load_balancing = true # For application load balancer this feature is always enabled (true) and cannot be disabled
  #   enable_deletion_protection = true

  access_logs {
    bucket  = var.website_access_logs_bucket_name
    prefix  = join("-", [var.project_name, "alb"])
    enabled = true
  }

  tags = {
    Name        = join("_", [var.project_name, "_app_alb"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_target_group" "backend_rds_app" {
  name                 = join("-", [var.project_name, "-app-tg"])
  port                 = local.backend_rds_app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.lb_deregistration_delay

  health_check {
    healthy_threshold   = var.lb_health_check_healthy_threshold
    interval            = var.lb_health_check_interval
    matcher             = "200"
    path                = var.lb_health_check_path
    protocol            = "HTTP"
    timeout             = var.lb_health_check_timeout
    unhealthy_threshold = var.lb_health_check_unhealthy_threshold
  }

  stickiness {
    type            = var.lb_stickiness_type
    cookie_duration = var.lb_cookie_duration
  }

  tags = {
    Name        = join("_", [var.project_name, "_app_tg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_target_group" "backend_redis_app" {
  name                 = join("-", [var.project_name, "-backend-redis-app-tg"])
  port                 = local.backend_redis_app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.lb_deregistration_delay

  health_check {
    healthy_threshold   = var.lb_health_check_healthy_threshold
    interval            = var.lb_health_check_interval
    matcher             = "200"
    path                = var.lb_health_check_path
    protocol            = "HTTP"
    timeout             = var.lb_health_check_timeout
    unhealthy_threshold = var.lb_health_check_unhealthy_threshold
  }

  stickiness {
    type            = var.lb_stickiness_type
    cookie_duration = var.lb_cookie_duration
  }

  tags = {
    Name        = join("_", [var.project_name, "_backend_redis_app_tg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = local.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = join("_", [var.project_name, "_app_lb_listener"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = local.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.this.arn

  default_action {
    type = "redirect"

    redirect {
      host        = local.website_domain_name
      port        = local.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = join("_", [var.project_name, "_app_lb_listener"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_listener_rule" "backend_rds" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_rds_app.arn
  }

  condition {
    host_header {
      values = ["api.lerkasan.net"]
    }
  }

  tags = {
    Name        = join("_", [var.project_name, "_backend_rds_app_lb_listener_rule"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_listener_rule" "backend_redis" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_redis_app.arn
  }

  condition {
    host_header {
      values = ["cache.lerkasan.net"]
    }
  }

  tags = {
    Name        = join("_", [var.project_name, "_backend_redis_app_lb_listener_rule"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_lb_listener_certificate" "api" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.api.arn
}

resource "aws_lb_listener_certificate" "cache" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.cache.arn
}