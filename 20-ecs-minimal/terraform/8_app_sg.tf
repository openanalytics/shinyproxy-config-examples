resource "aws_security_group" "app-sg" {
  name   = "${var.cluster_name}-app-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3838
    to_port         = 3838
    security_groups = [aws_security_group.shinyproxy-sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
