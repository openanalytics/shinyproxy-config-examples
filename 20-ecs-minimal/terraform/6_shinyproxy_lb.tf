resource "aws_security_group" "lb" {
  name   = "${var.cluster_name}-lb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_lb" "lb" {
  name            = "${var.cluster_name}-lb"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "lb" {
  name        = "${var.cluster_name}-lb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    path = "/actuator/health/readiness"
    port = 9090
  }
  # Ensures the ShinyProxy container keeps running for max ~1 hour if it' still being used by a websocket connection
  # after 1 hour the connections will be dropped
  deregistration_delay = "3600"

  tags = local.common_tags
}

resource "aws_lb_listener" "lb" {
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb.arn
    type             = "forward"
  }

  tags = local.common_tags
}
