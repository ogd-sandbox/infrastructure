resource "aws_iam_role" "gha_oidc_assume_role_applications" {
  name = "gha-oidc-assume-role-applications"

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
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : ["repo:ogd-sandbox/application:*"]
          }
        },

      }
    ]
  })
}

resource "aws_iam_role_policy" "gha_oidc_application_permissions" {
  name = "gha-oidc-application-permissions"
  role = aws_iam_role.gha_oidc_assume_role_applications.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

data "aws_iam_policy" "ecs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "gha_oidc_application_permission_role_policy_attach_ecs_full_access" {
  role       = aws_iam_role.gha_oidc_assume_role_applications.id
  policy_arn = "${data.aws_iam_policy.ecs_full_access.arn}"
}
