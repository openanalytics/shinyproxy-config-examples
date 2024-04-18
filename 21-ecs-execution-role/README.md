# Example: using a (Task) Execution role for an app

This example extends the [minimal ECS example](../20-ecs-minimal) by enabling
CloudWatch logs for apps and allowing to use images stored on ECR.

## Steps

1. Copy the files in
   the [`21-ecs-execution-role/terraform`](21-ecs-execution-role/terraform)
   directory to the [`20-ecs-minimal/terraform`](../20-ecs-minimal/terraform)
   directory:
   ```bash
   cp  21-ecs-execution-role/terraform/* 20-ecs-minimal/terraform
   ```
2. Go to the `20-ecs-minimal/terraform` directory:
   ```bash
   cd 20-ecs-minimal/terraform
   ```
3. Update the infrastructure:
   ```bash
   tofu apply -var-file=main.tfvars
   ```
   The final lines of the output will contain `app_execution_role=...` remember
   this values.
4. Modify the `20-ecs-minimal/docker/application.yml` file:
    - add the property `proxy.ecs.enable-cloudwatch: true`
    - add the property `ecs-execution-role` to app `01_hello`, using the ARN shown
      in the output of step 3
      (e.g. `ecs-execution-role: arn:aws:iam::012345678912:role/shinyproxy-config-examples-app-execution-role`)
5. [Update the ShinyProxy config](../20-ecs-minimal#updating-shinyproxy-configuration)
6. After you launch an app, you can view the logs in the AWS console

## Components

This section lists all of the additional components. Note that the numbering of
the files is solely to make it easier to understand, the file name has no
meaning to terraform.

- [`terraform/11_app_execution_role.tf`](terraform/11_app_execution_role.tf):
  creates an IAM role (**aws_iam_role.shinyproxy-app-execution-role**) that can
  be used as the execution role for apps.
  - the `assume_role_policy` (i.e. trust policy) gives permission for ECS to use
    this role
  - the `inline_policy` ensures that the executor has permission to create a
    CloudWatch log group for the app
  - the
    [`managed_policy_arns`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSTaskExecutionRolePolicy.html)
    ensures that the executor has permission to use AWS ECR for retrieving the
    ShinyProxy image and for pushing the logs into CloudWatch
  - this IAM role is very similar to the role created for ShinyProxy itself.
    However, for the sake of clarity it is better to use a separate role for
    ShinyProxy and for the apps. In addition, this makes it easier to extend
    either role.
- [`terraform/12_shinyproxy_task_role_policy.tf`](terraform/12_shinyproxy_task_role_policy.tf):
  provides an additional permission to the ShinyProxy Task role, such that
  ShinyProxy is allowed to create ECS tasks using the Execution role.
  - **aws_iam_policy.shinyproxy-pass-app-execution-role-policy**: an IAM policy
    that allows to use the app execution role.
  - **aws_iam_role_policy_attachment.shinyproxy-pass-app-execution-role-policy**:
    attaches the IAM policy to the ShinyProxy task role
