resource "aws_ecs_service" "shinyproxy-operator" {
  name            = "shinyproxy-operator"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.shinyproxy-operator.arn
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.shinyproxy-operator-sg.id]
  }

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  tags = local.common_tags
}
