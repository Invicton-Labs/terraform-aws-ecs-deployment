// Create a log group for the task to log to
module "task_log_group" {
  source  = "Invicton-Labs/log-group/aws"
  version = "~> 0.3.0"
  log_group_config = {
    name = "/ecs/task/${local.var_name}"
  }
}

locals {
  cloudwatch_log_configuration = {
    logDriver = "awslogs",
    options = {
      "awslogs-group" : module.task_log_group.log_group.name,
      "awslogs-region" : data.aws_region.current.name,
      "awslogs-stream-prefix" : local.var_name
    }
  }
}
resource "aws_ecs_task_definition" "this" {
  // Use a placeholder name, otherwise the workload workflow will try to update this existing task definition
  family = "${local.var_name}-placeholder"
  // These values are all placeholders and will be replaced on the first CI/CD deployment
  cpu          = 256
  memory       = 512
  network_mode = local.var_network_mode
  requires_compatibilities = [
    local.var_launch_type
  ]
  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  // It won't let us create an empty set of containers, so use a dummy one that will just fail to load
  container_definitions = jsonencode([
    {
      // If there's a target container for the ALB set, then it must exist even as a 
      // placeholder container. Otherwise, it will fail to create the service.
      name  = local.var_load_balancer_configuration != null ? local.var_load_balancer_configuration.container_name : "placeholder-container"
      image = "-"
      // Must map the ALB target group port, even as a placeholder container
      portMappings = local.var_load_balancer_configuration != null ? [
        {
          containerPort = local.var_load_balancer_configuration.container_port
        }
      ] : []
      // Default to CloudWatch logs
      logConfiguration = local.cloudwatch_log_configuration
    }
  ])
  tags = local.var_tags
}
