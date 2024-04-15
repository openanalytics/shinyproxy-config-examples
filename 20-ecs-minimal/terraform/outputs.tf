output "container_image_location" {
  value = aws_ecr_repository.shinyproxy-config-examples.repository_url
}

output "hostname" {
  value = aws_lb.lb.dns_name
}
