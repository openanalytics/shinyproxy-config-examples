resource "aws_iam_role" "shinyproxy-operator-task-role" {

  name = "${var.cluster_name}-shinyproxy-operator-task-role"

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

resource "aws_iam_policy" "shinyproxy-operator-ecs-policy" {
  name = "shinyproxy-operator-ecs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:DescribeServices",
          "ecs:StopTask",
          "ecs:TagResource",
          "ecs:DescribeTasks",
          "ecs:ListTagsForResource",
          "ecs:ListTaskDefinitions",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteTaskDefinitions",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid    = "LogsCreateGroup"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup"]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/ecs/shinyproxy-operator"
        ]
      },
      {
        Sid    = "LogsWriteStreams"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/ecs/shinyproxy-operator:log-stream:ecs-${var.cluster_name}*",
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjects",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.shinyproxy-operator-bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.shinyproxy-operator-bucket.id}/*"
        ]
      },
      {
        Sid    = "ElbDescribe"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
        ]
        Resource = "*"
      },
      {
        Sid    = "ElbCreateRuleOnOurLoadBalancer"
        Effect = "Allow"
        Action = ["elasticloadbalancing:CreateRule"]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:listener/app/${aws_lb.lb.name}/*/*",
        ]
      },
      {
        Sid    = "ElbModifyDeleteRulesOnOurLoadBalancer"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:DeleteRule",
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:listener-rule/app/${aws_lb.lb.name}/*/*/*",
        ]
      },
      {
        Sid    = "ElbTargetGroups"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:targetgroup/sp-*/*",
        ]
      },
      {
        Sid    = "ElbAddTags"
        Effect = "Allow"
        Action = ["elasticloadbalancing:AddTags"]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:targetgroup/sp-*/*",
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:listener-rule/app/${aws_lb.lb.name}/*/*/*",
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "shinyproxy-operator-ecs-policy" {
  role       = aws_iam_role.shinyproxy-operator-task-role.name
  policy_arn = aws_iam_policy.shinyproxy-operator-ecs-policy.arn
}
