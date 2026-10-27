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

resource "aws_lb_listener" "lb" {
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "200"
    }
  }

  tags = local.common_tags
}
