locals {
  pre = {
    aws = {
      profile = "default"
      region  = "eu-west-1"
      project = "transportes"
      owner   = "devops"
      resources = {
        vpc = {
          snet = {
            cidr                  = "10.11.24.0/22"
            secondary_cidr_blocks = ["10.97.0.0/16"]
            azs                   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
            public_subnets = {
              "a" : "10.11.24.0/27"
              "b" : "10.11.25.0/27"
              "c" : "10.11.26.0/27"
            }
            enable_nat_gateway           = true
            single_nat_gateway           = true
            create_database_subnet_group = true
            private_subnets = {
              "private-app-a" : "10.11.24.64/27"
              "private-app-b" : "10.11.25.64/27"
              "private-app-c" : "10.11.26.64/27"
              "private-eks-a" : "10.97.0.0/18"
              "private-eks-b" : "10.97.64.0/18"
              "private-eks-c" : "10.97.128.0/18"
            }
            database_subnets = {
              "private-rds-a" : "10.11.24.32/27"
              "private-rds-b" : "10.11.25.32/27"
              "private-rds-c" : "10.11.26.32/27"
            }
           } 
          }
        sg = {
          alb-ec2 = {
            vpc          = "snet"
            ingress_open = true
          }
          vpn-users = {
            vpc               = "snet"
            egress_restricted = false
          }
          vpn-cicd = {
            vpc               = "snet"
            egress_restricted = false
          }
          ec2-main = {
            vpc               = "snet"
            egress_restricted = false
            ingress = [
              {
                ports       = [{ from = 443 }]
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
              },
              {
                ports       = [{ from = 443 }, { from = 943 }, { from = 945 }, { from = 22 }]
                protocol    = "tcp"
                cidr_blocks = ["10.11.24.0/22"]
              }
            ]      
          }
          # vpn-users = {
          #   vpc               = "snet"
          #   egress_restricted = false
          # }
          # vpn-cicd = {
          #   vpc               = "snet"
          #   egress_restricted = false
          # }
        }
        # vpn = {
        #   users = {
        #     vpc       = "snet"
        #     sg        = "vpn-users"
        #     type      = "federated"
        #     saml_file = file("${path.root}/private/vpn-sso.xml")
        #     subnets   = ["private-app-a"] # OJO CON ESTO
        #   }
        #   cicd = {
        #     vpc     = "snet"
        #     sg      = "vpn-cicd"
        #     subnets = ["private-app-b"] # OJO CON ESTO
        #   }
        # }


        # ec2 = {
        #   insdet-01 = {
        #     #ami           = "ami-078cb96e4f4ce04a4" # OJO CON LA AMI
        #     instance_type = "t3.micro"
        #     monitoring    = true
        #     vpc           = "snet"
        #     subnet        = "private-app-a"
        #     sg            = "ec2-main"
        #     root_block_device = {
        #       encrypted   = true
        #       volume_size = 20
        #     }
        #     ebs_block_device = {
        #       sdb = {
        #         encrypted  = true
        #       }
        #     }
        #     tags = {
        #       map-migrated = "mig4Y9WUHC8WM"
        #     }
        #   }  
        # }
        # alb = {
        #   ec2 = {
        #     internal                         = true
        #     enable_cross_zone_load_balancing = true
        #     vpc                              = "snet"
        #     subnets                          = ["private-app-a", "private-app-b", "private-app-c"]
        #     sg                               = "alb-ec2"
        #     http_tcp_listeners = [
        #       {
        #         port        = 80
        #         protocol    = "HTTP"
        #         action_type = "redirect"
        #         redirect = {
        #           port        = "443"
        #           protocol    = "HTTPS"
        #           status_code = "HTTP_301"
        #         }
        #       }
        #     ]
        
        #     target_groups = [
        #       {
        #         name             = "geo"
        #         backend_protocol = "HTTP"
        #         backend_port     = 80
        #         target_type      = "instance"
        #         health_check = {
        #           interval            = 5
        #           path                = "/"
        #           port                = "traffic-port"
        #           protocol            = "HTTP"
        #           timeout             = 3
        #           healthy_threshold   = 3
        #           unhealthy_threshold = 3
        #           matcher             = "200-301"
        #         }
        #         targets = {
        #           first = {
        #             target_id = "insdet-01"
        #             port      = 8080
        #           }
        #         }
        #         tags = {}
        #       }
        #     ]
        #   }
        # }













      }













    }
  }
}