variable "name" {
  description = "The name of the ECS service/task."
  type        = string
  validation {
    condition     = var.name == null ? true : length(var.name) > 0
    error_message = "The `name` input variable may not be `null` or an empty string."
  }
}
locals {
  var_name = var.name
}

variable "cluster_arn" {
  description = "The ARN of the ECS cluster to deploy the service/task on."
  type        = string
  validation {
    condition     = var.cluster_arn == null ? true : length(var.cluster_arn) > 0
    error_message = "The `cluster_arn` input variable may not be `null` or an empty string."
  }
}
locals {
  var_cluster_arn = var.cluster_arn
}

variable "ecr_repositories_to_create" {
  description = "A map of names ECR repository names that should be created, to configuration values for that repository."
  type = map(object({
    create_lifecycle_policy  = bool
    lifecycle_policy         = any
    kms_key_id               = string
    create_repository_policy = bool
    repository_policy        = any
    mutable                  = bool
    scan_on_push             = bool
  }))
  default = {}
}
locals {
  var_ecr_repositories_to_create = coalesce(var.ecr_repositories_to_create, {})
}

variable "execution_role_policy_jsons" {
  description = "A map of inline policies to attach to the IAM execution role used for the ECS task, where keys are the policy names and values are the JSON-encoded policy documents."
  type        = map(string)
  default     = {}
}
locals {
  var_execution_role_policy_jsons = coalesce(var.execution_role_policy_jsons, {})
}

variable "execution_role_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the IAM execution role used for the ECS task."
  type        = list(string)
  default     = []
}
locals {
  var_execution_role_policy_arns = coalesce(var.execution_role_policy_arns, [])
}

variable "task_role_policy_jsons" {
  description = "A map of inline policies to attach to the IAM task role used for the ECS task, where keys are the policy names and values are the JSON-encoded policy documents."
  type        = map(string)
  default     = {}
}
locals {
  var_task_role_policy_jsons = coalesce(var.task_role_policy_jsons, {})
}

variable "task_role_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the IAM task role used for the ECS task."
  type        = list(string)
  default     = []
}
locals {
  var_task_role_policy_arns = coalesce(var.task_role_policy_arns, [])
}

variable "launch_type" {
  description = "The launch type to use for the ECS task/service."
  type        = string
  validation {
    condition     = var.launch_type != null
    error_message = "The `launch_type` input variable may not be `null`."
  }
}
locals {
  var_launch_type = var.launch_type
}

variable "network_mode" {
  description = "The network mode to use for the ECS task."
  type        = string
  validation {
    condition     = var.network_mode != null
    error_message = "The `network_mode` input variable may not be `null`."
  }
}
locals {
  var_network_mode = var.network_mode
}

variable "network_configuration" {
  description = "The network configuration for the ECS service."
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = bool
  })
  default = null
  validation {
    condition     = var.network_configuration == null ? true : length([for k, v in var.network_configuration : k if v == null]) == 0
    error_message = "None of the fields of the `network_configuration` input variable may be `null`."
  }
}
locals {
  var_network_configuration = var.network_configuration
}

variable "desired_count" {
  description = "The desired number of task instances to run for the service. This value is only used if the `autoscaling_configuration` input variable is not provided."
  type        = number
  default     = null
}
locals {
  var_desired_count = var.desired_count
}

variable "autoscaling_configuration" {
  description = "Configuration for autoscaling settings."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
  validation {
    condition     = var.autoscaling_configuration == null ? true : length([for k, v in var.autoscaling_configuration : k if v == null]) == 0
    error_message = "None of the fields of the `autoscaling_configuration` input variable may be `null`."
  }
}
locals {
  var_autoscaling_configuration = var.autoscaling_configuration
}

variable "load_balancer_configuration" {
  description = "Configuration for an optional load balancer integration."
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
  validation {
    condition     = var.load_balancer_configuration == null ? true : length([for k, v in var.load_balancer_configuration : k if v == null]) == 0
    error_message = "None of the fields of the `load_balancer_configuration` input variable may be `null`."
  }
}
locals {
  var_load_balancer_configuration = var.load_balancer_configuration
}

variable "github_configuration" {
  description = "Configuration for an optional GitHub integration."
  type = object({
    repository       = string
    environment      = string
    use_environments = bool
  })
  default = null
  validation {
    condition     = var.github_configuration == null ? true : var.github_configuration.repository != null
    error_message = "The `repository` field of the `github_configuration` input variable may not be `null`."
  }
  validation {
    condition     = var.github_configuration.environment == null ? true : length(regexall("^[0-9a-zA-Z_.-]*$")) == 1
    error_message = "The `environment` field of the `github_configuration` input variable must match the regex ^[0-9a-zA-Z_.-]*$."
  }
}
locals {
  var_github_configuration = var.github_configuration
}

variable "runtime_parameters" {
  description = "An object with all necessary runtime parameters for the application."
  type        = any
  default     = {}
  validation {
    condition     = var.runtime_parameters == null ? true : can(keys(var.runtime_parameters))
    error_message = "The `runtime_parameters` input variable must be a map or object."
  }
}
locals {
  // This JSON nonsense is a workaround for a known limitation of Terraform: https://github.com/hashicorp/terraform/issues/31412
  var_runtime_parameters = jsondecode(var.runtime_parameters != null ? jsonencode(var.runtime_parameters) : jsonencode({}))
}

variable "tags" {
  description = "Tags to apply to all resources created in this module."
  type        = map(string)
  default     = {}
}
locals {
  var_tags = coalesce(var.tags, {})
}
