resource "aws_s3_object" "shinyproxy-config" {
  bucket = aws_s3_bucket.shinyproxy-operator-bucket.id
  key    = "input/realm1.shinyproxy.yaml"
  content = templatefile("realm1.shinyproxy.yaml", {
    loadbalancer_fqdn = aws_lb.lb.dns_name
    ecs_cluster_name = var.cluster_name
    ecs_subnet_0 = module.vpc.private_subnets[0]
    ecs_subnet_1 = module.vpc.private_subnets[1]
    ecs_region = var.aws_region
    ecs_security_group = aws_security_group.app-sg.id
  })

}
