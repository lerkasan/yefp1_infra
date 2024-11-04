resource "aws_kms_key" "database_encrypt_key" {
  description             = "A key to encrypt database"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = join("_", [var.project_name, "_database_encrypt_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_kms_key" "ssm_param_encrypt_key" {
  description             = "A key to encrypt SSM parameters"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = join("_", [var.project_name, "_ssm_param_encrypt_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_kms_grant" "decrypt_access_for_ec2" {
  name              = "decrypt_access_for_ec2"
  key_id            = aws_kms_key.ssm_param_encrypt_key.id
  grantee_principal = var.iam_role_arn
  operations        = ["Decrypt"]
}
