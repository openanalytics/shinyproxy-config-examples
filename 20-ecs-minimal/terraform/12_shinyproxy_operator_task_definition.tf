resource "aws_ecs_task_definition" "shinyproxy-operator" {
  family                   = "shinyproxy-operator"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = jsonencode([
    {
      name         = "shinyproxy-operator"
      image        = "openanalytics/shinyproxy-operator-snapshot:2.4.0-SNAPSHOT-20261027.133047"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name = "SPO_CLOUD_WATCH_REGION"
          value = var.aws_region
        },
        {
          name  = "SPO_ECS_CLUSTER_NAME"
          value = aws_ecs_cluster.ecs.name
        },
        {
          name = "SPO_ECS_LISTENER_ARN"
          value = aws_lb_listener.lb.arn
        },
        {
          name= "SPO_ECS_S3_BUCKET"
          value = aws_s3_bucket.shinyproxy-operator-bucket.id
        },
        {
          name  = "SPO_ECS_SECURITY_GROUPS"
          value = aws_security_group.shinyproxy-sg.id
        },
        {
          name  = "SPO_ECS_SUBNETS"
          value = "${module.vpc.private_subnets[0]},${module.vpc.private_subnets[1]}"
        },
        {
          name  = "SPO_ECS_VPC_ID"
          value = module.vpc.vpc_id
        },
        {
          name = "SPO_EXECUTION_ROLE_ARN"
          value = aws_iam_role.shinyproxy-execution-role.arn
        },
        {
          name = "SPO_TASK_ROLE_ARN"
          value = aws_iam_role.shinyproxy-task-role.arn
        },
        {
          name = "SPO_ORCHESTRATOR"
          value = "ECS"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-region"        = var.aws_region
          "awslogs-group"         = var.cluster_name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "shinyproxy-operator"
        }
      }
      stopTimeout = 120
    }
  ])

  task_role_arn      = aws_iam_role.shinyproxy-operator-task-role.arn
  execution_role_arn = aws_iam_role.shinyproxy-operator-execution-role.arn

  tags = local.common_tags
}
