resource "aws_ecs_task_definition" "shinyproxy" {
  family                   = "shinyproxy"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = jsonencode([
    {
      name         = "shinyproxy"
      image        = aws_ecr_repository.shinyproxy-config-examples.repository_url
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "CLUSTER_NAME"
          value = aws_ecs_cluster.ecs.name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "SUBNET_0"
          value = module.vpc.private_subnets[0]
        },
        {
          name  = "SUBNET_1"
          value = module.vpc.private_subnets[1]
        },
        {
          name  = "SECURITY_GROUP"
          value = aws_security_group.app-sg.id
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-region"        = var.aws_region
          "awslogs-group"         = var.cluster_name
          "awslogs-create-group"  = "true"
          "awslogs-stream-prefix" = "shinyproxy"
        }
      }
      stopTimeout = 120
    }
  ])

  task_role_arn      = aws_iam_role.shinyproxy-task-role.arn
  execution_role_arn = aws_iam_role.shinyproxy-execution-role.arn

  tags = local.common_tags
}
