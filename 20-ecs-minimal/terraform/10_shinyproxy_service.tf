resource "aws_ecs_service" "shinyproxy" {
  name            = "shinyproxy"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.shinyproxy.arn
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.shinyproxy-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb.arn
    container_name   = "shinyproxy"
    container_port   = 8080
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  tags = local.common_tags
}
