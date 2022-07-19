data "aws_arn" "cluster" {
  arn = local.var_cluster_arn
}

resource "aws_appautoscaling_target" "ecs" {
  count              = local.var_autoscaling_configuration != null ? 1 : 0
  min_capacity       = local.var_autoscaling_configuration.min_capacity
  max_capacity       = local.var_autoscaling_configuration.max_capacity
  resource_id        = "service/${trimprefix(data.aws_arn.cluster.resource, "cluster")}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
