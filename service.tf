module "assert_desired_count" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.1"
  condition     = local.var_autoscaling_configuration != null || local.var_desired_count != null
  error_message = "Either the `autoscaling_configuration` or the `desired_count` input variable must be provided."
}

resource "aws_ecs_service" "this" {
  depends_on = [
    module.assert_desired_count
  ]
  name            = local.var_name
  cluster         = local.var_cluster_arn
  launch_type     = local.var_launch_type
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = local.var_autoscaling_configuration != null ? null : local.var_desired_count

  // Set up the load balancer config, if desired
  dynamic "load_balancer" {
    for_each = local.var_load_balancer_configuration != null ? [1] : []
    content {
      target_group_arn = local.var_load_balancer_configuration.target_group_arn
      container_name   = local.var_load_balancer_configuration.container_name
      container_port   = local.var_load_balancer_configuration.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = local.var_network_mode == "awsvpc" ? [1] : []
    content {
      subnets          = local.var_network_configuration.subnets
      security_groups  = local.var_network_configuration.security_groups
      assign_public_ip = local.var_network_configuration.assign_public_ip
    }
  }

  tags = local.var_tags

  lifecycle {
    ignore_changes = [
      // Ignore task definition since it's created and managed outside this
      // Terraform config (by the deployment pipeline for the workload).
      task_definition,
    ]
  }
}
