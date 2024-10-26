data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [ local.ami_name ]
  }

  filter {
    name   = "architecture"
    values = [ local.ami_architecture ]
  }

  filter {
    name   = "virtualization-type"
    values = [ var.ami_virtualization ]
  }

  owners = [ local.ami_owner_id ]
}

data "aws_ssm_parameter" "admin_public_ssh_keys" {
  for_each = toset(var.admin_public_ssh_keys)

  name = each.value
  with_decryption = true
}

data "cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/userdata.tftpl", {
      public_ssh_keys: [ for key in data.aws_ssm_parameter.admin_public_ssh_keys: key.value]
    })
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    sid           = "EC2AssumeRole"
    effect        = "Allow"
    actions       = [ "sts:AssumeRole" ]
    principals {
      type        = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "read_access_to_parameters_and_deployments" {
  statement {
    sid       = "CodeDeployGetDeployments"
    effect    = "Allow"
    actions   = [
      "codedeploy:GetDeployment",
      "codedeploy:ListDeployments"
    ]
    resources = [ var.codedeploy_deployment_group_arn ]
  }

  statement {
    sid       = "SSMGetParameter"
    effect    = "Allow"
    actions   = [ "ssm:GetParameter" ]
    resources = [
      var.ssm_param_db_host_arn,
      var.ssm_param_db_name_arn,
      var.ssm_param_db_username_arn,
      var.ssm_param_db_password_arn
    ]
  }

  statement {
    sid       = "KMSDecrypt"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [ var.kms_key_arn ]
  }

  statement {
    sid       = "CloudWatchLogs"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = [ "*" ]
  }
}

data "aws_iam_policy_document" "connect_to_ec2_via_ec2_instance_connect_endpoint" {
  statement {
    sid     = "EC2ConnectEndpoint"
    effect  = "Allow"
    actions = [
      "ec2-instance-connect:OpenTunnel"
    ]
    resources = [ aws_ec2_instance_connect_endpoint.this.arn ]

    condition {
      test     = "NumericEquals"
      variable = "ec2-instance-connect:remotePort"
      values   = [local.ssh_port]
    }
  }

  statement {
    sid     = "EC2DescribeConnectEndpoints"
    effect  = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceConnectEndpoints"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "pull_only_access_to_ecr" {
  statement {
    sid       = "PullOnlyFromECR"
    effect    = "Allow"
    actions   = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchImportUpstreamImage"
    ]
    resources = [ for repo_name in var.ecr_repository_names: "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.id}:repository/${repo_name}" ]
  }

  statement {
    sid = "LoginToECR"
    effect = "Allow"
    actions = [ "ecr:GetAuthorizationToken" ]
    resources = [ "*" ]
  }
}