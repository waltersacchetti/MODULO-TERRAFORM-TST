variable "aws" {
  description = "Main AWS configuration"
  type = object({
    profile = string
    region  = string
    project = string
    owner   = string
    tags    = optional(map(string))
    resources = object({
      alb = optional(map(object({
        internal                         = optional(bool, false)
        vpc                              = string
        sg                               = optional(string, null)
        subnets                          = list(string)
        enable_cross_zone_load_balancing = optional(bool, false)
        enable_deletion_protection       = optional(bool, false)
        drop_invalid_header_fields       = optional(bool, false)
        tags                             = optional(map(string), {})
        lb_tags                          = optional(map(string), {})
        http_tcp_listeners               = optional(any, [])
        https_listeners                  = optional(any, [])
        https_listener_rules             = optional(any, [])
        target_groups = optional(list(object({
          name                   = string
          backend_protocol       = string
          backend_port           = number
          target_type            = optional(string, null)
          deregistration_delay   = optional(number, null)
          connection_termination = optional(bool, null)
          preserve_client_ip     = optional(bool, null)
          protocol_version       = optional(string, null)
          health_check = optional(object({
            interval            = optional(number, null)
            path                = optional(string, null)
            matcher             = optional(string, null)
            port                = optional(string, null)
            protocol            = optional(string, null)
            healthy_threshold   = optional(number, null)
            unhealthy_threshold = optional(number, null)
            timeout             = optional(number, null)
          }), null)
          targets = optional(map(object({
            target_id = string
            port      = optional(number, null)
          })), null)
          tags = optional(map(string), {})
        })), [])
      })), {})
      nlb = optional(map(object({
        internal                         = optional(bool, false)
        vpc                              = string
        sg                               = optional(string, null)
        subnets                          = list(string)
        enable_cross_zone_load_balancing = optional(bool, false)
        enable_deletion_protection       = optional(bool, false)
        tags                             = optional(map(string), {})
        lb_tags                          = optional(map(string), {})
        http_tcp_listeners               = optional(any, [])
        https_listeners                  = optional(any, [])
        https_listener_rules             = optional(any, [])
        target_groups = optional(list(object({
          name                   = string
          backend_protocol       = string
          backend_port           = number
          target_type            = optional(string, null)
          deregistration_delay   = optional(number, null)
          connection_termination = optional(bool, null)
          preserve_client_ip     = optional(bool, null)
          protocol_version       = optional(string, null)
          health_check = optional(object({
            interval            = optional(number, null)
            path                = optional(string, null)
            matcher             = optional(string, null)
            port                = optional(string, null)
            protocol            = optional(string, null)
            healthy_threshold   = optional(number, null)
            unhealthy_threshold = optional(number, null)
            timeout             = optional(number, null)
          }), null)
          targets = optional(map(object({
            target_id = string
            port      = optional(number, null)
          })), null)
          tags = optional(map(string), {})
          stickiness = optional(object({
            type            = optional(string, "source_ip")
            cookie_duration = optional(number, null)
          }), null)
        })), [])
      })), {})
      alternat = optional(object({
        image_uri             = optional(string, "0123456789012.dkr.ecr.us-east-1.amazonaws.com/alternat-functions-lambda")
        image_tag             = optional(string, "v0.3.3")
        instance_type         = optional(string, "c6gn.large")
        lambda_package_type   = optional(string, "Zip")
        max_instance_lifetime = optional(number, 1209600)
        sgs                   = optional(list(string), [])
        vpc                   = optional(string, null)
      }), {})
      vpc = optional(map(object({
        tags                  = optional(map(string), {})
        cidr                  = string
        secondary_cidr_blocks = optional(list(string), [])
        azs                   = list(string)

        enable_nat_gateway   = optional(bool, true)
        single_nat_gateway   = optional(bool, true)
        enable_vpn_gateway   = optional(bool, false)
        enable_dns_hostnames = optional(bool, true)
        enable_dns_support   = optional(bool, true)

        public_subnets  = optional(map(string), {})
        private_subnets = optional(map(string), {})

        create_database_subnet_group           = optional(bool, false)
        create_database_subnet_route_table     = optional(bool, null)
        create_database_internet_gateway_route = optional(bool, false)
        database_subnets                       = optional(map(string), {})

        create_elasticache_subnet_group       = optional(bool, false)
        create_elasticache_subnet_route_table = optional(bool, null)
        elasticache_subnets                   = optional(map(string), {})

        vgw_dx = optional(map(object({
          amazon_side_asn  = optional(string, null)
          allowed_prefixes = optional(list(string), [])
          account_id       = string
          dx_gw_id         = string
          subnets          = optional(list(string), [])
        })), {})

        private_nat_gateway = optional(list(string), [])
        routes = optional(map(list(object({
          cidr_block          = string
          private_nat_gateway = optional(string, null)
          transit_gateway     = optional(string, null)
        }))), {})

      })), {})
      vpn = optional(map(object({
        sg   = string
        vpc  = string
        type = optional(string, "certificate")

        tags                  = optional(map(string), {})
        client_cidr_block     = optional(string, "192.168.100.0/22")
        transport_protocol    = optional(string, null)
        split_tunnel          = optional(bool, true)
        vpn_port              = optional(number, 443)
        session_timeout_hours = optional(number, 8)
        access_group_id       = optional(string, null)

        saml_file = optional(string, null)

        subnets             = optional(list(string), ["app-a"])
        target_network_cidr = optional(string, "0.0.0.0/0")
      })), {})
      sg = optional(map(object({
        tags              = optional(map(string), {})
        vpc               = string
        egress_restricted = optional(bool, true)
        ingress_open      = optional(bool, false)
        ingress = optional(list(object({
          ports = list(object({
            from = number
            to   = optional(number, null)
          }))
          protocol               = optional(string, "tcp")
          source_security_groups = optional(list(string), [])
          cidr_blocks            = optional(list(string), [])
        })), [])
      })), {})
      ec2 = optional(map(object({
        instance_type               = optional(string, "t3.micro")
        key_name                    = optional(string, null)
        monitoring                  = optional(bool, false)
        associate_public_ip_address = optional(bool, null)
        ami                         = optional(string, null)
        vpc                         = optional(string, null)
        subnet                      = optional(string, null)
        sg                          = optional(string, null)
        key_pair_tags               = optional(map(string), {})
        user_data                   = optional(string, null)
        user_data_replace_on_change = optional(bool, null)
        tags                        = optional(map(string), {})
        root_block_device = optional(object({
          delete_on_termination = optional(bool, true)
          encrypted             = optional(bool, false)
          kms_key_id            = optional(string, null)
          iops                  = optional(number, null)
          volume_type           = optional(string, "gp3")
          throughput            = optional(number, 125)
          volume_size           = optional(number, 100)
          tags                  = optional(map(string), {})
        }), {})
        ebs_block_device = optional(map(object({
          encrypted  = optional(bool, false)
          type       = optional(string, "gp3")
          throughput = optional(number, 125)
          size       = optional(number, 100)
          kms_key_id = optional(string, null)
          iops       = optional(number, null)
          tags       = optional(map(string), {})
          attach     = optional(bool, true)
        })), {})
        iam_role_policies = optional(map(string), {})
        network_interfaces = optional(list(object({
          vpc    = string
          subnet = string
          sg     = string
        })), [])
      })), {})
      eks = optional(map(object({
        tags            = optional(map(string), {})
        cluster_version = optional(string, "1.26")

        vpc     = string
        subnets = list(string)
        sg      = string
        public  = optional(bool, true)
        cicd    = optional(bool, true)

        aws_auth_roles = optional(list(object({
          arn      = string
          username = string
          groups   = optional(list(string), [])
        })), [])

        iam_role_additional_policies = optional(map(string), null)

        eks_managed_node_groups = optional(map(object({
          ami_type                              = optional(string, "AL2_x86_64")
          desired_size                          = optional(number, 1)
          max_size                              = optional(number, 2)
          min_size                              = optional(number, 1)
          instance_type                         = optional(string, "t3.medium")
          kubelet_extra_args                    = optional(string, "")
          subnets                               = optional(list(string), [])
          block_device_mappings                 = optional(any, null)
          default_block_device_mappings_cmk_key = optional(string, null)
          labels                                = optional(map(string), {})
          taints = optional(list(object({
            key    = string
            value  = string
            effect = string
          })), [])
          tags = optional(map(string), {})
        })), {})
        role_binding = optional(list(object({
          username    = string
          clusterrole = string
          namespaces  = list(string)
        })), [])
        cluster_role_binding = optional(list(object({
          username    = string
          clusterrole = string
        })), [])
        namespaces     = optional(list(string), [])
        cluster_addons = optional(map(map(string)), null)
      })), {})
      iam = optional(object({
        iam_policy = optional(map(object({
          policy_file = optional(string, null)
          statements = optional(list(object({
            actions   = list(string)
            effect    = optional(string, "Allow")
            resources = list(string)
            conditions = optional(list(object({
              test     = string
              variable = string
              values   = optional(list(string), [])
            })), [])
          })), [])
          tags = optional(map(string), {})
        })), {})
        iam_role = optional(map(object({
          trusted_entity_statements = list(object({
            actions = list(string)
            effect  = optional(string, "Allow")
            principals = list(object({
              type  = string
              value = optional(list(string), [])
            }))
            conditions = optional(list(object({
              test     = string
              variable = string
              values   = optional(list(string), [])
            })), [])
          }))
          attach_policy_keys      = optional(list(string), [])
          role_requires_mfa       = optional(bool, false)
          create_instance_profile = optional(bool, false)
          tags                    = optional(map(string), {})
        })), {})
      }), {})
      kms = optional(map(object({
        deletion_window_in_days                = optional(number, 30)
        enable_key_rotation                    = optional(bool, true)
        key_usage                              = optional(string, "ENCRYPT_DECRYPT")
        key_owners                             = optional(list(string), [])
        key_administrators                     = optional(list(string), [])
        key_users                              = optional(list(string), [])
        key_service_users                      = optional(list(string), [])
        key_service_roles_for_autoscaling      = optional(list(string), [])
        key_symmetric_encryption_users         = optional(list(string), [])
        key_hmac_users                         = optional(list(string), [])
        key_asymmetric_public_encryption_users = optional(list(string), [])
        key_asymmetric_sign_verify_users       = optional(list(string), [])
        key_statements                         = optional(any, {})
        aliases                                = optional(list(string), [])
        computed_aliases                       = optional(any, {})
        grants                                 = optional(any, {})
        tags                                   = optional(map(string), {})
      })), {})

    })
  })




}