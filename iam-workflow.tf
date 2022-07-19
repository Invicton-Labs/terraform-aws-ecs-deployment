// Create an IAM user for the workflow to use
resource "aws_iam_user" "workflow" {
  name = "workflow-${local.var_name}"
  tags = local.var_tags
}

// Create an access key for the user
resource "aws_iam_access_key" "workflow" {
  user = aws_iam_user.workflow.name
}

// Allow the user and the account root to assume the role
data "aws_iam_policy_document" "user_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_user.workflow.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

// Create a role for running the workflow
resource "aws_iam_role" "workflow" {
  name               = aws_iam_user.workflow.name
  assume_role_policy = data.aws_iam_policy_document.user_assume.json
  tags               = local.var_tags
}

// The policy document for the workflow user's permission
data "aws_iam_policy_document" "workflow" {
  source_policy_documents = [
    // Allow pulling and pushing to the ECR repos
    data.aws_iam_policy_document.ecr_push_and_pull[0].json,
  ]

  // Allow reading the configuration parameter
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.workflow.arn
    ]
  }

  // Allow registering and deregistering task definitions
  statement {
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
    ]
    resources = [
      "*"
    ]
  }

  // Allow updating the ECS service with the new task definition
  statement {
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      aws_ecs_service.this.id
    ]
  }

  // Allow it to pass the regional ECS task and execution roles to
  // the task definition that it creates.
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.execution.arn,
      aws_iam_role.task.arn,
    ]
  }
}

// Attach the workflow policy to the workflow role
resource "aws_iam_role_policy" "workflow" {
  role   = aws_iam_role.workflow.name
  name   = "workflow"
  policy = data.aws_iam_policy_document.workflow.json
}
