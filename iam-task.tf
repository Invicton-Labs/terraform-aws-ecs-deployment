// A policy document that allows ECS tasks to assume a role
data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    // Allow ECS to assume the role, so the task can use it
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
    // Allow this account to assume the role, for local development testing of the role's policy
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

// Create a role for the task to run as
resource "aws_iam_role" "task" {
  name               = "ecs-${local.var_name}-task-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = local.var_tags
}

data "aws_iam_policy_document" "task" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.runtime.arn
    ]
  }
}

// Attach the policy with task permissions we need to add ourselves
resource "aws_iam_role_policy" "task" {
  role   = aws_iam_role.task.name
  name   = "read-runtime-ssm-parameter"
  policy = data.aws_iam_policy_document.task.json
}

// Attach all of the JSON policy documents (direct attachment)
resource "aws_iam_role_policy" "task_external" {
  // We use count instead of for_each because count can be known at plan time,
  // even if the contents of each element aren't known.
  count  = length(local.var_task_role_policy_jsons)
  role   = aws_iam_role.task.name
  name   = keys(local.var_task_role_policy_jsons)[count.index]
  policy = values(local.var_task_role_policy_jsons)[count.index]
}

// Attach all of the IAM policies (by ARN)
resource "aws_iam_role_policy_attachment" "task_external" {
  count      = length(local.var_task_role_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = local.var_task_role_policy_arns[count.index]
}
