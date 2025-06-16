# Example: running ShinyProxy on ECS (using ECS backend)

This example demonstrates how to run ShinyProxy on ECS, while using the ECS
backend to host apps. This example uses opentofu/terraform to configure
the infrastructure. Even when not using opentofue/terraform, this is useful,
since the code explains all the configuration that's required for this example.

## Overview

This deployment creates an ECS cluster, running the ShinyProxy server. An
Application LoadBalancer is created to route traffic into ShinyProxy. The
configuration of ShinyProxy is stored
in [`docker/application.yml`](docker/application.yml) and is used to build a
custom Docker image which is stored on ECR (this currently the most
straightforward approach to handling config on ECS, although for non-demo
purposes you could use something better). See [Components](#components) for a
detailed list of resources created.

## Steps

In order to deploy this example:

1. Install [opentofu](https://github.com/opentofu/opentofu)
   or [terraform](https://github.com/hashicorp/terraform)
2. Go to the `20-ecs-minimal/terraform` directory:
   ```bash
   cd 20-ecs-minimal/terraform
   ```
3. Configure [`terraform/main.tfvars`](terraform/main.tfvars)
    - fill in your AWS account id, region and zones
    - choose a name for the ECS cluster. Note that other resources use the
      cluster name as part of their name.
4. Initialize:
   ```bash
   tofu init
   ```
5. Create the infrastructure by running:
   ```bash
   tofu apply -var-file=main.tfvars
   ````
   The final lines of the output will contain `container_image_location=...`
   and `hostname=...`, remember these values.
6. Build and push the Docker image (replace `$container_image_location` by the
   output of the previous command):
   ```bash
   cd docker
   docker build -t $container_image_location
   docker push $container_image_location
   ```
7. Wait 1-2 minutes for the ECS task to use the new image
8. Open ShinyProxy using the hostname from step 4
9. You can now log using the username `jack` and password `password`

## Updating ShinyProxy configuration

In order to update the ShinyProxy Configuration:

1. Update the [`docker/application.yml`](docker/application.yml) file
2. Build and push the docker image:
   ```bash
   cd docker
   docker build -t $container_image_location
   docker push $container_image_location
   ```
3. Go to the AWS ECS console, click on your cluster
4. Click on the `shinyproxy` service
5. Click on the `Update service` in the top right corner
6. Select `Force new deployment`
7. Click on `Update`
8. Wait for the new service to be ready

## Components

This section lists all components of the infrastructure. Note that the numbering
of the files is solely to make it easier to understand, the file name has no
meaning to terraform.

- [`terraform/1_shinyproxy_image.tf`](terraform/1_shinyproxy_image.tf): ECR
  repository to store the ShinyProxy image (containing a
  custom `application.yml`)
- [`terraform/2_vpc.tf`](terraform/2_vpc.tf): VPC
- [`terraform/3_ecs.tf`](terraform/3_ecs.tf): ECS Fargate cluster
- [`terraform/4_shinyproxy_task_role.tf`](terraform/4_shinyproxy_task_role.tf):
  creates an IAM role that acts as the Task Role for the ShinyProxy service:
  - **aws_iam_role.shinyproxy-task-role**: the IAM role used as Task Role,
    the `assume_role_policy` (i.e. trust policy) gives permission for ECS to use
    this role
  - **aws_iam_policy.shinyproxy-ecs-policy**: provides the permission to create
    ECS tasks
  - **aws_iam_role_policy_attachment.shinyproxy-ecs-policy**: attaches the
    policy to the role
- [`terraform/5_shinyproxy_execution_role.tf`](terraform/5_shinyproxy_execution_role.tf):
  creates an IAM role (**aws_iam_role.shinyproxy-execution-role**) that acts as
  the Execution role (sometimes also called Task Execution role) for the
  executor of the ShinyProxy service (the permissions in this role aren't given
  to ShinyProxy).
  - the `assume_role_policy` (i.e. trust policy) gives permission for ECS to use
    this role
  - the `inline_policy` ensures that the executor has permission to create a
    CloudWatch log group for ShinyProxy
  - the
    [`managed_policy_arns`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSTaskExecutionRolePolicy.html)
    ensures that the executor has permission to use AWS ECR for retrieving the
    ShinyProxy image and for pushing the logs into CloudWatch
- [`terraform/6_shinyproxy_lb.tf`](terraform/6_shinyproxy_lb.tf): configures a
  LoadBalancer:
  - **aws_security_group.lb**: creates a security group for the LoadBalancer,
    such that it's accessible from the internet
  - **aws_lb.lb**: creates
    an [Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
  - **aws_lb_target_group.lb** creates a target group for the LoadBalancer (ECS
    automatically puts the ShinyProxy container as a target in it)
  - **aws_lb_listener.lb** creates a listener group for the LoadBalancer (the
    port on which it's accessible)
- [`terraform/7_shinyproxy_sg.tf`](terraform/7_shinyproxy_sg.tf): creates a
  security group (**aws_security_group.shinyproxy-sg**) for ShinyProxy:
  - ensures ShinyProxy can be accessed by the LoadBalancer
  - since the ShinyProxy Task is using this security group, it can be used
    as `source` in other security group rules
- [`terraform/8_app_sg.tf`](terraform/8_app_sg.tf): creates a
  security group (**aws_security_group.app-sg**) for the Shiny apps hosted on
  ShinyProxy, it ensures ShinyProxy can access the apps on port 3838
- [`terraform/9_shinyproxy_task_defintion.tf`](terraform/9_shinyproxy_task_defintion.tf):
  creates an ECS Task Definition (**aws_ecs_task_definition.shinyproxy**) for
  running ShinyProxy on ECS:
  - uses the ECR image
  - passes the ids of the resources created in terraform as environment
    variables to ShinyProxy
  - uses CloudWatch for storing the logs of ShinyProxy (not of the apps)
  - uses the task and execution role ARNs
- [`terraform/10_shinyproxy_service.tf`](terraform/10_shinyproxy_service.tf):
  creates the ECS service that runs ShinyProxy:
  - uses the cluster created in step 3
  - uses the task definition created in step 8
  - uses the subnets created in the VPC in step 2
  - uses the security group created in step 7
  - connects to the loadbalancer created step 6

## Limitations

The setup in this directory can only use public Docker images for the apps. In
order to use an image stored on ECR,
see [21-ecs-execution-role](../21-ecs-execution-role).

## References

- [ECS Backend configuration](https://shinyproxy.io/documentation/configuration/#ecs)
- [ECS App configuration](https://shinyproxy.io/documentation/configuration/#ecs-1)
