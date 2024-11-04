data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "allow_cloudfront_access_only" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

data "aws_iam_policy_document" "allow_elb_logging" {
  statement {
    sid     = "AllowLoadBalancerWriteOnly"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    resources = ["${aws_s3_bucket.this.arn}/${var.project_name}-alb/*"]
  }
}