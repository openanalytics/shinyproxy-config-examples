# Example: using Redis on ECS

This example extends the [minimal ECS example](../20-ecs-minimal) by using
Redis for app and session persistence. When using the operator (on ECS) it's
mandatory to use Redis. The AWS Redis service, called ElastiCache, is used.

## Steps

1. Copy the files in
   the [`22-ecs-redis-terraform`](terraform)
   directory to the [`20-ecs-minimal/terraform`](../20-ecs-minimal/terraform)
   directory:
   ```bash
   cp  22-ecs-redis/terraform/* 20-ecs-minimal/terraform
   ```
2. Go to the `20-ecs-minimal/terraform` directory:
   ```bash
   cd 20-ecs-minimal/terraform
   ```
3. Update the infrastructure:
   ```bash
   tofu apply -var-file=main.tfvars
   ```
   The final lines of the output will contain `secret_arn=...` remember
   this value.
4. Modify the `20-ecs-minimal/realm1.shinyproxy.yml` file:
    - replace the ARN in the secret definition with the arn from the previous
      step
5. Update the infrastructure:
   ```bash
   tofu apply -var-file=main.tfvars
   ```
6. Wait for the new instance to start up
7. The new instance now uses Redis. When deploying new configuration changes,
   both the HTTP session and the app sessions of users will continue to work,
   while the new configuration is seamlessly deployed in the background.

## Components

This section lists all of the additional components. Note that the numbering of
the files is solely to make it easier to understand, the filename has no
meaning to terraform.

- [`terraform/19_redis.tf`](terraform/19_redis.tf):
  - creates a random password for the Redis server
  - creates an ElastiCache Redis instance
  - stores the password and hostname in an AWS Secrets Manager secret
  - gives the ShinyProxy services permission to fetch the secret  
