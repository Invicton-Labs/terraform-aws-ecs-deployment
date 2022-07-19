locals {
  workflow_config = jsonencode(merge(flatten([
    {
      cluster_arn                  = var.cluster_arn
      service_name                 = aws_ecs_service.this.name
      task_definition_family       = local.var_name
      runtime_ssm_parameter        = aws_ssm_parameter.runtime.name
      execution_role_arn           = aws_iam_role.execution.arn
      task_role_arn                = aws_iam_role.task.arn
      network_mode                 = local.var_network_mode
      cloudwatch_log_configuration = local.cloudwatch_log_configuration
    },
    length(module.ecr_repositories) > 0 ? [{
      ecr = {
        for k, v in module.ecr_repositories :
        k => {
          domain = split("/", v.repository_url)[0]
          image  = v.repository_url
        }
      }
    }] : [],
    local.var_load_balancer_configuration != null ? [{
      load_balancer_container_name = local.var_load_balancer_configuration.container_name
      load_balancer_container_port = local.var_load_balancer_configuration.container_port
    }] : []
  ])...))

  runtime_config = jsonencode(local.var_runtime_parameters)
}

resource "aws_ssm_parameter" "workflow" {
  name  = "/workflow/${local.var_name}"
  type  = "SecureString"
  tier  = length(local.workflow_config) > 4096 ? "Advanced" : "Standard"
  value = local.workflow_config
  tags  = local.var_tags
}

resource "aws_ssm_parameter" "runtime" {
  name  = "/runtime/${local.var_name}"
  type  = "SecureString"
  tier  = length(local.runtime_config) > 4096 ? "Advanced" : "Standard"
  value = local.runtime_config
  tags  = local.var_tags
}
