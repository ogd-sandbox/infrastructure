resource "aws_iam_role" "gha_oidc_assume_role_infrastucture" {
  name = "gha-oidc-assume-role-infrastucture"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.github_actions.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:sub" : ["repo:ogd-sandbox/infrastucture:*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "gha_oidc_infrastucture_permissions" {
  name = "gha-oidc-infrastucture-permissions"
  role = aws_iam_role.gha_oidc_assume_role_infrastucture.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = "*",
        Resource = "*"
      },
    ]
  })
}
