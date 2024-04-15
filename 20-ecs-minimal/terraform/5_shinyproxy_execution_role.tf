resource "aws_iam_role" "shinyproxy-execution-role" {

  name = "${var.cluster_name}-execution-role"

  assume_role_policy = jsonencode(
    {
      Version   = "2012-10-17"
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

  inline_policy {
    name = "ecs-logs"

    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]

  tags = local.common_tags
}
