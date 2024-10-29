data "aws_iam_policy_document" "allow_cloudfront_access_only" {
    statement {
      sid       = "AllowCloudFrontServicePrincipalReadOnly"
      effect    = "Allow"
      actions   = ["s3:GetObject"]

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