resource "aws_iam_instance_profile" "this" {
  name = join("_", [var.project_name, "_ec2_profile"])
  role = aws_iam_role.appserver_iam_role.name
}

resource "aws_iam_role" "appserver_iam_role" {
  name        = join("", [title(var.project_name), "AppserverRole"])
  description = "The role for EC2 instances for appserver"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_policy" "read_access_to_parameters_and_deployments" {
  name        = "read-access-to-parameters-and-deployments"
  description = "Allow to get deployment information to retrieve a commitId hash"
  policy      = data.aws_iam_policy_document.read_access_to_parameters_and_deployments.json
}

resource "aws_iam_role_policy_attachment" "get_deployment_and_ssm_parameter" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = aws_iam_policy.read_access_to_parameters_and_deployments.arn
}

resource "aws_iam_policy" "connect_via_ec2_instance_connect_endpoint" {
  name        = "ec2-instance-connect"
  description = "Allow to connect to EC2 instance via EC2 Instance Connect Endpoint"
  policy      = data.aws_iam_policy_document.connect_to_ec2_via_ec2_instance_connect_endpoint.json
}

resource "aws_iam_role_policy_attachment" "connect_via_ec2_instance_connect_endpoint" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = aws_iam_policy.connect_via_ec2_instance_connect_endpoint.arn
}

resource "aws_iam_policy" "pull_only_access_to_ecr" {
  name        = "pull-only-from-ecr"
  description = "Allow to login to ECR and pull images from ECR"
  policy      = data.aws_iam_policy_document.pull_only_access_to_ecr.json
}

resource "aws_iam_role_policy_attachment" "pull_only_access_to_ecr_from_ec2" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = aws_iam_policy.pull_only_access_to_ecr.arn
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
