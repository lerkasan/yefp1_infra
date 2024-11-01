data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_sign_key_policy" {
  statement {
    sid     = "ECRSignVerifyKeyPolicy"
    effect  = "Allow"
    actions = [
      "kms:Sign",
      "kms:Verify",
      "kms:DescribeKey"
    ]
    principals {
      type = "AWS"
      identifiers = [ aws_iam_role.github_ecr_role.arn ]
    }
    resources = ["*"]
  }

  statement {
    sid = "AllowRootAllActionsOnKey"
    effect = "Allow"
    actions = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "allow_github_to_use_ecr_sign_key" {
#   statement {
#     sid = "AllowRootAllActionsOnKey"
#     effect = "Allow"
#     actions = ["kms:*"]
#     resources = ["*"]

#     principals {
#       type = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#   }

  statement {
    sid     = "AllowECRSignVerifyKeyUse"
    effect  = "Allow"
    actions = [
      "kms:DescribeCustomKeyStores",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:DisconnectCustomKeyStore",
      "kms:ConnectCustomKeyStore",
      "kms:GetPublicKey",
      "kms:DescribeKey",
      "kms:Sign",
      "kms:TagResource"
    ]

    # principals {
    #   type = "AWS"
    #   identifiers = [ aws_iam_role.github_ecr_role.arn ]
    # }

    resources = [
      aws_kms_key.ecr_sign_key.arn,
      aws_kms_alias.ecr_sign_key_alias.arn
    ]
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
        type = "Federated"
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
        values   = [
          "repo:${statement.value}:*"
        ]
      }

    #   condition {
    #     test     = "StringEquals"
    #     variable = "token.actions.githubusercontent.com:sub"
    #     values   = [
    #       "repo:${statement.value}:ref:refs/heads/main"
    #     ]
    #   }
    }
  }
}

data "aws_iam_policy_document" "allow_github_role_to_use_codedeploy" {
  statement {
    sid     = "AllowGithubRoleToUseCodeDeploy"
    effect  = "Allow"
    actions = [
      "codedeploy:Batch*",
      "codedeploy:CreateDeployment",
      "codedeploy:Get*",
      "codedeploy:List*",
      "codedeploy:RegisterApplicationRevision"
    ]
    # principals {
    #   type = "AWS"
    #   identifiers = [ aws_iam_role.github_codedeploy_role.arn ]
    # }

    resources = ["*"]
  }
}