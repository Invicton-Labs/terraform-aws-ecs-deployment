# Terraform AWS ECS Deployment

This module creates an ECS task definition and service, along with autoscaling and appropriate IAM roles, and optionally integrates with a GitHub Actions workflow. It is intended for use with workloads where the infrastructure is managed with Terraform in an infrastructure repository, but the build/deploy of the application code (and associated ECS task definition) is done separately.
