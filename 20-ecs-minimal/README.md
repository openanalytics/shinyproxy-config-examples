# Example: running ShinyProxy on ECS (using ECS backend)

This example demonstrates how to run ShinyProxy on ECS, while using the ECS
backend to host apps. This example uses opentofu/terraform to configure
the infrastructure. Even when not using opentofu/terraform, this is useful,
since the code explains all the configuration that's required for this example.

## Overview

This deployment creates an ECS cluster, running the ShinyProxy Operator. An
Application LoadBalancer is created to route traffic into ShinyProxy. The
configuration of ShinyProxy is stored
in [`terraform/realm1.shinyproxy.yaml`](terraform/realm1.shinyproxy.yaml), which
is uploaded to an S3 bucket. See [Components](#components) for a detailed list
of resources created.

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
   The final lines of the output will contain `hostname=...`, remember this
   value.
6. Wait for the operator to run.
7. Wait for the operator to create the ShinyProxy instance.
8. Open ShinyProxy using the hostname from step 4
9. You can now log using the username `jack` and password `password`

## Updating ShinyProxy configuration

In order to update the ShinyProxy Configuration:

1. Update the [`terraform/main.tfvars`](terraform/main.tfvars) file
2. Update the infrastructure:
   ```bash
   tofu apply -var-file=main.tfvars
   ```
3. Wait for the operator to create the new ShinyProxy instance.

## Components

This section lists all components of the infrastructure. Note that the numbering
of the files is solely to make it easier to understand, the file name has no
meaning to terraform.

- [`terraform/1_vpc.tf`](terraform/1_vpc.tf): VPC
- [`terraform/2_ecs.tf`](terraform/2_ecs.tf): ECS Fargate cluster
- [`terraform/3_shinyproxy_task_role.tf`](terraform/3_shinyproxy_task_role.tf):
  creates an IAM role that acts as the Task Role for the ShinyProxy service:
  - **aws_iam_role.shinyproxy-task-role**: the IAM role used as Task Role,
    the `assume_role_policy` (i.e. trust policy) gives permission for ECS to use
    this role
  - **aws_iam_policy.shinyproxy-ecs-policy**: provides the permission to create
    ECS tasks
  - **aws_iam_role_policy_attachment.shinyproxy-ecs-policy**: attaches the
    policy to the role
- [`terraform/4_shinyproxy_execution_role.tf`](terraform/4_shinyproxy_execution_role.tf):
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
- [`terraform/5_shinyproxy_lb.tf`](terraform/5_shinyproxy_lb.tf): configures a
  LoadBalancer:
  - **aws_security_group.lb**: creates a security group for the LoadBalancer,
    such that it's accessible from the internet
  - **aws_lb.lb**: creates
    an [Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
  - **aws_lb_listener.lb** creates a listener for the LoadBalancer (the
    port on which it's accessible). Note that the operator creates the target
    group and listener rules.
- [`terraform/6_shinyproxy_sg.tf`](terraform/6_shinyproxy_sg.tf): creates a
  security group (**aws_security_group.shinyproxy-sg**) for ShinyProxy:
  - ensures ShinyProxy can be accessed by the LoadBalancer
  - since the ShinyProxy Task is using this security group, it can be used
    as `source` in other security group rules
- [`terraform/7_app_sg.tf`](terraform/7_app_sg.tf): creates a
  security group (**aws_security_group.app-sg**) for the Shiny apps hosted on
  ShinyProxy, it ensures ShinyProxy can access the apps on port 3838
- [`terraform/8_shinyproxy_operator_s3.tf`](terraform/8_shinyproxy_operator_s3.tf):
  creates an
  S3 bucket (**aws_s3_bucket.shinyproxy-operator-bucket**) for storing the
  ShinyProxy configuration file and the state of the ShinyProxy Operator.
  This should not be used to secrets.
- [`terraform/9_shinyproxy_operator_execution_role.tf`](terraform/9_shinyproxy_operator_execution_role.tf):
  creates the execution role for the ShinyProxy Operator
  (**aws_iam_role.shinyproxy-operator-execution-role**). Used to have the
  logs of the operator logged into CloudWatch.
- [`terraform/10_shinyproxy_operator_task_role.tf`](terraform/10_shinyproxy_operator_task_role.tf):
  creates the task role for the ShinyProxy Operator
  (**aws_iam_role.shinyproxy-operator-task-role**). The role gives the Operator
  permission to create new ECS services, create a CloudWatch Log group, manage
  the files in the S3 bucket and configure the loadbalancer.
- [`terraform/11_shinyproxy_operator_sg.tf`](terraform/11_shinyproxy_operator_sg.tf):
  creates a security group for the operator
  (**aws_security_group.shinyproxy-operator-sg**). The operator requires no
  ingress rules, but the group is used to allow traffic to the ShinyProxy
  services (see [`terraform/6_shinyproxy_sg.tf`](terraform/6_shinyproxy_sg.tf)).
  This is used by the Operator to check whether an instance is recyclable.
- [`terraform/12_shinyproxy_operator_task_definition.tf`](terraform/12_shinyproxy_operator_task_definition.tf):
  creates an ECS Task Definition (**aws_ecs_task_definition.shinyproxy-operator**)
  for running the ShinyProxy Operator.
- [`terraform/13_shinyproxy_operator_service.tf`](terraform/13_shinyproxy_operator_service.tf):
  creates the ECS service that runs the ShinyProxy Operator.
- [`terraform/14_shinyproxy_operator_task_role_policy.tf`](terraform/14_shinyproxy_operator_task_role_policy.tf):
  gives the ShinyProxy Operator permission to pass the executor and task role of ShinyProxy.
- [`terraform/15_shinyproxy_config.tf`](terraform/15_shinyproxy_config.tf):
  uploads the ShinyProxy configuration file to the S3 bucket.

## Limitations

The setup in this directory can only use public Docker images for the apps. In
order to use an image stored on ECR,
see [21-ecs-execution-role](../21-ecs-execution-role).

## References

- [ECS Backend configuration](https://shinyproxy.io/documentation/configuration/#ecs)
- [ECS App configuration](https://shinyproxy.io/documentation/configuration/#ecs-1)
