output "task_role_arn" {
  description = "The ARN of the IAM role that the task will run as."
  value       = aws_iam_role.task.arn
}
output "task_role_name" {
  description = "The name of the IAM role that the task will run as."
  value       = aws_iam_role.task.name
}
