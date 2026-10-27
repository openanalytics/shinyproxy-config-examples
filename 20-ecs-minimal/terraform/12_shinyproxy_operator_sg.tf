resource "aws_security_group" "shinyproxy-operator-sg" {
  name   = "${var.cluster_name}-shinyproxy-operator-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
