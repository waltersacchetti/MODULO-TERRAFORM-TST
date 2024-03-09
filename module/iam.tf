# ╔══════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                             Locals                                           ║
# ╚══════════════════════════════════════════════════════════════════════════════════════════════╝
locals {
  iam_list_policies = flatten([
    for key, value in var.aws.resources.iam.iam_policy : [{
      iam_policy  = key
      policy_file = value.policy_file
      statements  = value.statements
      tags        = value.tags
    }]
  ])

  iam_map_policies = {
    for value in local.iam_list_policies : value.iam_policy => value
  }

  iam_list_roles = flatten([
    for key, value in var.aws.resources.iam.iam_role : [{
      iam_role                  = key
      role_requires_mfa         = value.role_requires_mfa
      custom_role_policy_keys   = value.attach_policy_keys
      trusted_entity_statements = value.trusted_entity_statements
      create_instance_profile   = value.create_instance_profile
      tags                      = value.tags
    }]
  ])

  iam_map_roles = {
    for value in local.iam_list_roles : value.iam_role => value
  }

}
# ╔══════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                             Data                                             ║
# ╚══════════════════════════════════════════════════════════════════════════════════════════════╝
data "aws_iam_policy_document" "assume_role_policy" {
  for_each = local.iam_map_roles
  dynamic "statement" {
    for_each = each.value.trusted_entity_statements
    content {
      sid     = "Statement${statement.key}"
      effect  = statement.value.effect
      actions = [for action in statement.value.actions : action]
      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = [for idt in principals.value.value : idt]
        }
      }
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = [for val in condition.value.values : val]
        }
      }
    }
  }
}

data "aws_iam_policy_document" "this" {
  for_each = can(local.iam_map_policies.policy_file) ? {} : local.iam_map_policies
  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = "Statement${statement.key}"
      effect    = statement.value.effect
      actions   = [for action in statement.value.actions : action]
      resources = [for resource in statement.value.resources : resource]
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = [for val in condition.value.values : val]
        }
      }
    }
  }
}

# ╔══════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                             Module                                           ║
# ╚══════════════════════════════════════════════════════════════════════════════════════════════╝
resource "aws_iam_policy" "this" {
  for_each = local.iam_map_policies
  name     = "${local.translation_regions[var.aws.region]}-${var.aws.profile}-iam-policy-${each.key}"
  policy   = each.value.policy_file != null ? each.value.policy_file : data.aws_iam_policy_document.this[each.key].json
  tags     = merge(local.common_tags, each.value.tags)
}

module "iam_role" {
  source            = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version           = "5.30.0"
  for_each          = local.iam_map_roles
  role_name         = "${local.translation_regions[var.aws.region]}-${var.aws.profile}-iam-role-${each.key}"
  create_role       = true
  role_requires_mfa = each.value.role_requires_mfa
  custom_role_policy_arns = each.value.custom_role_policy_keys != [] ? [
    for policy in each.value.custom_role_policy_keys :
    can(aws_iam_policy.this[policy].arn) ? aws_iam_policy.this[policy].arn : ""
  ] : []
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.assume_role_policy[each.key].json
  create_instance_profile         = each.value.create_instance_profile
  tags                            = merge(local.common_tags, each.value.tags)
}