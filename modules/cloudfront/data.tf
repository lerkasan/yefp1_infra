data "aws_caller_identity" "current" {}

data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "managed_managed_cors_s3_origin" {
  name = "Managed-CORS-S3Origin"
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_iam_policy_document" "allow_github_role_to_upload_to_s3" {
  statement {
    sid    = "AllowGithubRoleToUploadToS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["${var.s3_bucket_arn}/*"]
  }

  statement {
    sid    = "AllowGithubRoleToListS3Bucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]

    resources = [var.s3_bucket_arn]
  }
}

data "aws_iam_policy_document" "allow_github_role_to_create_cloudfront_invalidation" {
  statement {
    sid    = "AllowGithubRoleToCreateCloudFrontInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [aws_cloudfront_distribution.this.arn]
  }
}

data "aws_iam_policy_document" "trust_policy_for_github_roles" {
  dynamic "statement" {
    for_each = toset(var.github_repositories)

    content {
      #   sid     = "TrustPolicyForGithubECRRole"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/token.actions.githubusercontent.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }

      # https://github.com/aws-actions/configure-aws-credentials/issues/1137#issuecomment-2308716791
      # https://github.com/aws-actions/configure-aws-credentials/issues/1137#issuecomment-2305041118
      condition {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values = [
          "repo:${statement.value}:*"
        ]
      }
    }
  }
}