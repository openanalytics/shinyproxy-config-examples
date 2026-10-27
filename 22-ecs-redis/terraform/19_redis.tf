module "this" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = ""
  environment = ""
}

resource "random_password" "redis-auth-token" {
  length           = 40
  special          = true
  override_special = "!&#$^<>-"
}

module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "2.1.0"

  name                          = "${var.cluster_name}-shinyproxy"
  vpc_id                        = module.vpc.vpc_id
  allowed_security_group_ids    = [aws_security_group.shinyproxy-sg.id]
  elasticache_subnet_group_name = module.vpc.elasticache_subnet_group_name
  cluster_size                  = 2

  instance_type              = "cache.t4g.micro"
  cluster_mode_enabled       = false
  auto_minor_version_upgrade = true
  apply_immediately          = true
  automatic_failover_enabled = true
  engine_version             = "7.1"
  family                     = "redis7"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  multi_az_enabled           = true

  auth_token = random_password.redis-auth-token.result

  parameter = [
    {
      name  = "notify-keyspace-events"
      value = "AKE"
    }
  ]

  context = module.this.context
}

resource "aws_secretsmanager_secret" "redis-auth-token-secret" {
  name = "${var.cluster_name}-redis-auth-token"
}

resource "aws_secretsmanager_secret_version" "redis-auth-token-secret" {
  secret_id = aws_secretsmanager_secret.redis-auth-token-secret.id
  secret_string = jsonencode({
    "REDIS_PASSWORD" : random_password.redis-auth-token.result
    "REDIS_HOST" : module.redis.endpoint
  })
}

resource "aws_iam_role_policy" "shinyproxy-execution-role-secrets" {
  name = "${var.cluster_name}-secrets-policy"
  role = aws_iam_role.shinyproxy-execution-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_secretsmanager_secret.redis-auth-token-secret.arn]
      }
    ]
  })
}

output "secret_arn" {
  value = aws_secretsmanager_secret.redis-auth-token-secret.arn
}
