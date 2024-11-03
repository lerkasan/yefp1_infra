module "ecr_repository" {
  for_each = toset(var.ecr_repository_names)
  
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=841b3c7d4b15adaca3dfc7a49f41c70ae03dd17b"   # commit hash for version 2.3.0
#   source  = "terraform-aws-modules/ecr/aws"
#   version = "2.3.0"

  repository_name = each.key
  repository_type = var.ecr_repository_type

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last N number of images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = var.ecr_images_limit
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_policy = jsonencode({
	Version   = "2012-10-17"
	Statement = [
      {
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
        ]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.id}:user/${module.ecr_user.iam_user_name}"
        }
        Sid = "PrivateReadOnly"
      },
      {
        Action = [
          "ecr:UploadLayerPart",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
        ]
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.id}:user/${module.ecr_user.iam_user_name}"
        }
        Sid = "ReadWrite"
      },
    ]
})

  registry_scan_type = var.ecr_repository_scan_type

  tags = {
    Name        = join("_", [var.project_name, "_ecr"])
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_key" "ecr_sign_key" {
  description             = "A key to sign docker images in ECR"
  customer_master_key_spec = "RSA_4096"
  key_usage               = "SIGN_VERIFY"
  deletion_window_in_days = 10
#   enable_key_rotation     = true
  policy = data.aws_iam_policy_document.ecr_sign_key_policy.json

  tags = {
    Name        = join("_", [var.project_name, "_ecr_sign_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_kms_alias" "ecr_sign_key_alias" {
  name          = "alias/yefp1-ecr-sign-key"
  target_key_id = aws_kms_key.ecr_sign_key.key_id
}