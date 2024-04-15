resource "aws_ecr_repository" "shinyproxy-config-examples" {

  name = "shinyproxy-config-examples"

  tags = local.common_tags
}
