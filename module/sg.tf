module "sg" {
  source   = "terraform-aws-modules/security-group/aws"
  version  = "5.1.0"
  for_each = var.aws.resources.sg
  name     = "${local.translation_regions[var.aws.region]}-${var.aws.profile}-sg-${each.key}"
  vpc_id   = module.vpc[each.value.vpc].vpc_id
  tags     = merge(local.common_tags, each.value.tags)

  egress_with_cidr_blocks = each.value.egress_restricted == true ? [for cidr in concat([module.vpc[each.value.vpc].vpc_cidr_block], module.vpc[each.value.vpc].vpc_secondary_cidr_blocks) :
    {
      rule        = "all-all"
      cidr_blocks = cidr
    }
    ] : [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_cidr_blocks = each.value.ingress_open == true ? ["0.0.0.0/0"] : []
  ingress_rules       = each.value.ingress_open == true ? ["all-all"] : []
}

module "sg_ingress_rules" {
  source            = "terraform-aws-modules/security-group/aws"
  version           = "5.1.0"
  for_each          = var.aws.resources.sg
  create_sg         = false
  security_group_id = module.sg[each.key].security_group_id
  ingress_with_source_security_group_id = flatten([
    for value in each.value.ingress : [
      for sg in value.source_security_groups : [
        for port in value.ports : {
          from_port                = port.from
          to_port                  = port.to != null ? port.to : port.from
          protocol                 = value.protocol
          source_security_group_id = module.sg[sg].security_group_id
          description              = "${value.protocol}/${port.from} - Access from ${sg} to ${each.key}"
        }
      ]
    ]
  ])
  ingress_with_cidr_blocks = flatten([
    for value in each.value.ingress : [
      for cidr in value.cidr_blocks : [
        for port in value.ports : {
          from_port   = port.from
          to_port     = port.to != null ? port.to : port.from
          protocol    = value.protocol
          cidr_blocks = cidr
          description = "${value.protocol}/${port.from} - Access from ${cidr} to ${each.key}"
        }
      ]
    ]
  ])
}