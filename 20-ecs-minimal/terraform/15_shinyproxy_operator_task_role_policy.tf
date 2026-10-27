resource "aws_iam_policy" "shinyproxy-operator-pass-app-execution-role-policy" {
  name   = "${var.cluster_name}-operator-pass-app-execution-role-policy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      # allow ShinyProxy to create tasks with the execution role
      {
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:PassRole"
        ],
        Resource = [
          aws_iam_role.shinyproxy-task-role.arn,
          aws_iam_role.shinyproxy-execution-role.arn
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "shinyproxy-operator-pass-app-execution-role-policy" {
  role       = aws_iam_role.shinyproxy-operator-task-role.name
  policy_arn = aws_iam_policy.shinyproxy-operator-pass-app-execution-role-policy.arn
}
