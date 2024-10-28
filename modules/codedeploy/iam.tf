resource "aws_iam_role" "codedeploy" {
#   name               = "codedeployRole"
  name               = join("_", ["codedeployRole", var.codedeploy_app_name])
  assume_role_policy = data.aws_iam_policy_document.assume_role_codedeploy.json
}

resource "aws_iam_role_policy_attachment" "aws_codedeploy_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}