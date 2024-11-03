module "ecr_user" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-user?ref=cfb6845f1fb0cf34438b640bd69ee81f7b38332f"   # commit hash for version 5.47.1	
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#   version = "5.47.1"

  name                          = var.ecr_user_name
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  policy_arns = [ 
    module.allow_push_to_ecr_iam_policy.arn
  ]
}

module "allow_push_to_ecr_iam_policy" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=cfb6845f1fb0cf34438b640bd69ee81f7b38332f"   # commit hash for version 5.47.1	
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.47.1"

  name    = "allow-full-access-to-ecr"

  policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Action = [
        #   "ecr:*"
        # ]
        Action = [
          "ecr:ListTagsForResource",
          "ecr:ListImages",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetLifecyclePolicy",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:UploadLayerPart",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [for repo_name in var.ecr_repository_names: "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.id}:repository/${repo_name}"]
      },
      {
        Effect = "Allow"
        Action = [ "ecr:GetAuthorizationToken" ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "github_ecr_role" {
  name        = join("", [title(var.project_name), "github_ecr_role"])
  description = "The role for Github Actions to sign docker images and push them to ECR"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  assume_role_policy = data.aws_iam_policy_document.trust_policy_for_github_roles.json

  tags = {
    Name        = join("_", [var.project_name, "_github_ecr_role"])
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role" "github_codedeploy_role" {
  name        = join("", [title(var.project_name), "github_codedeploy_role"])
  description = "The role for Github Actions to deploy backend via CodeDeploy"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  assume_role_policy = data.aws_iam_policy_document.trust_policy_for_github_roles.json

  tags = {
    Name        = join("_", [var.project_name, "_github_ecr_role"])
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_policy" "github_codedeploy_policy" {
  name        = join("-", [var.project_name, "github-codedeploy-policy"])
  description = "Allow Github Actions to use CodeDeploy"
  policy      = data.aws_iam_policy_document.allow_github_role_to_use_codedeploy.json
}

resource "aws_iam_role_policy_attachment" "allow_to_use_codedeploy" {
  role       = aws_iam_role.github_codedeploy_role.name
  policy_arn = aws_iam_policy.github_codedeploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "allow_push_to_ecr" {
  role       = aws_iam_role.github_ecr_role.name
  policy_arn = module.allow_push_to_ecr_iam_policy.arn
}

resource "aws_iam_policy" "github_sign_ecr_policy" {
  name        = join("-", [var.project_name, "github-sign-ecr-policy"])
  description = "Allow Github Actions to sign docker images on ECR"
  policy      = data.aws_iam_policy_document.allow_github_to_use_ecr_sign_key.json
}

resource "aws_iam_role_policy_attachment" "allow_to_user_ecr_sign_key" {
  role       = aws_iam_role.github_ecr_role.name
  policy_arn = aws_iam_policy.github_sign_ecr_policy.arn
}