locals {
  secret_value = jsonencode({
    region            = data.aws_region.current.name
    access_key_id     = aws_iam_access_key.workflow.id
    access_key_secret = aws_iam_access_key.workflow.secret
    ssm_parameter     = aws_ssm_parameter.workflow.name
  })

  // If we're not using environment secrets, and an environment was provided, append the environment name to the secret name
  secret_name = local.var_github_configuration != null ? (
    "ECS_DEPLOYMENT_WORKFLOW_CONFIG${local.var_github_configuration.use_environments != true && local.var_github_configuration.environment != null ? "-${local.var_github_configuration.environment}" : ""}"
  ) : ""

  // Use GitHub's environment secret if we're told to use it, and an environment was provided
  use_env_secret = local.var_github_configuration != null ? (
    local.var_github_configuration.use_environments == true && local.var_github_configuration.environment != null
  ) : false
}

resource "github_actions_environment_secret" "workflow" {
  count           = local.use_env_secret ? 1 : 0
  repository      = local.var_github_configuration.repository
  environment     = local.var_github_configuration.environment
  secret_name     = local.secret_name
  plaintext_value = local.secret_value
}

resource "github_actions_secret" "workflow" {
  // Create an Actions secret if we're not creating an environment secret, AND a GitHub configuration was provided
  count           = !local.use_env_secret && local.var_github_configuration != null ? 1 : 0
  repository      = local.var_github_configuration.repository
  secret_name     = local.secret_name
  plaintext_value = local.secret_value
}
