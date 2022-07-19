module "ecr_repositories" {
  //source                   = "Invicton-Labs/ecr-repository/aws"
  //version                  = "~>0.1.1"
  source                   = "../terraform-aws-ecr-repository"
  for_each                 = local.var_ecr_repositories_to_create
  name                     = each.key
  create_lifecycle_policy  = each.value.create_lifecycle_policy
  lifecycle_policy         = each.value.lifecycle_policy
  kms_key_id               = each.value.kms_key_id
  create_repository_policy = each.value.create_repository_policy
  repository_policy        = each.value.repository_policy
  mutable                  = each.value.mutable
  scan_on_push             = each.value.scan_on_push
  tags                     = local.var_tags
}

data "aws_iam_policy_document" "ecr_pull" {
  count = length(module.ecr_repositories) > 0 ? 1 : 0
  source_policy_documents = [
    for mod in module.ecr_repositories :
    mod.pull_policy_json
  ]
}

data "aws_iam_policy_document" "ecr_push_and_pull" {
  count = length(module.ecr_repositories) > 0 ? 1 : 0
  source_policy_documents = flatten([
    for mod in module.ecr_repositories :
    [
      // Allow pushing to all ECR repos (push new images)
      mod.push_policy_json,
      // Allow pulling from all ECR repos (pulling freshly built images for running tests)
      mod.pull_policy_json,
    ]
  ])
}
