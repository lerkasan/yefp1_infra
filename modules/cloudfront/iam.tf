resource "aws_iam_role" "github_cloudfront_role" {
  name        = join("", [title(var.project_name), "github_cloudfront_role"])
  assume_role_policy = data.aws_iam_policy_document.trust_policy_for_github_roles.json
}

resource "aws_iam_policy" "github_s3_policy" {
  name        = join("-", [var.project_name, "github-s3-policy"])
  description = "Allow Github Actions to use S3"
  policy      = data.aws_iam_policy_document.allow_github_role_to_upload_to_s3.json
}

resource "aws_iam_role_policy_attachment" "allow_to_use_s3" {
  role       = aws_iam_role.github_cloudfront_role.name
  policy_arn = aws_iam_policy.github_s3_policy.arn
}

resource "aws_iam_policy" "github_cloudfront_policy" {
  name        = join("-", [var.project_name, "github-cloudfront-policy"])
  description = "Allow Github Actions to use CloudFront"
  policy      = data.aws_iam_policy_document.allow_github_role_to_create_cloudfront_invalidation.json
}

resource "aws_iam_role_policy_attachment" "allow_to_use_cloudfront" {
  role       = aws_iam_role.github_cloudfront_role.name
  policy_arn = aws_iam_policy.github_cloudfront_policy.arn
}