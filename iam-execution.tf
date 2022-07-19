// The policy document that allows ECS tasks to assume a role
data "aws_iam_policy_document" "execution_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

// Create a role to be used for executing the cluster to pull containers and do other clustery things
resource "aws_iam_role" "execution" {
  name               = "ecs-${local.var_name}-execution-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json
  tags               = local.var_tags
}

// Attach all of the JSON policy documents (direct attachment)
resource "aws_iam_role_policy" "execution" {
  // We use count instead of for_each because count can be known at plan time,
  // even if the contents of each element aren't known.
  count  = length(local.var_execution_role_policy_jsons)
  role   = aws_iam_role.execution.name
  name   = keys(local.var_execution_role_policy_jsons)[count.index]
  policy = values(local.var_execution_role_policy_jsons)[count.index]
}

// Attach all of the IAM policies (by ARN)
resource "aws_iam_role_policy_attachment" "execution" {
  count      = length(local.var_execution_role_policy_arns)
  role       = aws_iam_role.execution.name
  policy_arn = local.var_execution_role_policy_arns[count.index]
}

// Attach an inline policy that allows pulling from the ECR repositories
resource "aws_iam_role_policy" "execution_ecr" {
  count  = length(data.aws_iam_policy_document.ecr_pull)
  role   = aws_iam_role.execution.name
  name   = "ecr-pull"
  policy = data.aws_iam_policy_document.ecr_pull[0].json
}

// Allow the cluster execution role to log to the task log group
resource "aws_iam_role_policy" "execution_logging" {
  role   = aws_iam_role.execution.name
  name   = "cloudwatch-logging"
  policy = module.task_log_group.logging_policy_json
}
