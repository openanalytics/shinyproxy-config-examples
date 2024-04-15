resource "aws_iam_role" "shinyproxy-task-role" {

  name = "${var.cluster_name}-task-role"

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
    name = "shinyproxy"

    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecs:RunTask",
            "ecs:ListTasks",
            "ecs:StopTask",
            "ecs:DescribeTasks",
            "ecs:ListTagsForResource",
            "ecs:RegisterTaskDefinition",
            "ecs:DeregisterTaskDefinition",
            "ecs:DeleteTaskDefinitions"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = local.common_tags
}
