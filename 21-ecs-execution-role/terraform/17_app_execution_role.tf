resource "aws_iam_role" "shinyproxy-app-execution-role" {
  name = "${var.cluster_name}-app-execution-role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = [
              "ecs-tasks.amazonaws.com"
            ]
          },
          Action = "sts:AssumeRole",
          Condition = {
            ArnLike = {
              "aws:SourceArn" = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:*"
            },
            StringEquals = {
              "aws:SourceAccount" = var.aws_account_id
            }
          }
        }
      ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "shinyproxy-app-execution-role-ecs-logs" {
  name = "ecs-logs"
  role = aws_iam_role.shinyproxy-app-execution-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "shinyproxy-app-execution-role-ecs-task-execution" {
  role       = aws_iam_role.shinyproxy-app-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "app_execution_role" {
  value = aws_iam_role.shinyproxy-app-execution-role.arn
}
