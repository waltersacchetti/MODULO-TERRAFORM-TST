provider "azurerm" {
  features {}
}

provider "aws" {
  region  = local.pre.aws.region
  profile = local.pre.aws.profile
}


# provider "kubernetes" {
#   host                   = module.aws.eks_config.host
#   cluster_ca_certificate = module.aws.eks_config.cluster_ca_certificate
#   #version = "~> 1.11"
#   exec {
#     api_version = module.aws.eks_config.api_version
#     command     = module.aws.eks_config.command
#     args        = module.aws.eks_config.args
#   }
#   # config_path    = "data/${terraform.workspace}/eks/main/admin.kubeconfig"
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.aws.eks_config.host
#     cluster_ca_certificate = module.aws.eks_config.cluster_ca_certificate
#     exec {
#       api_version = module.aws.eks_config.api_version
#       command     = module.aws.eks_config.command
#       args        = module.aws.eks_config.args
#     }
#     # config_path    = "data/${terraform.workspace}/eks/main/admin.kubeconfig"
#   }
# }
# terraform {
#   backend "azurerm" {
#     resource_group_name = "mova"
#     storage_account_name = "movastorage"
#     container_name   = "precticmem-pre"
#     key = "terraform.tfstate"
#     subscription_id  = "ffce92c4-a130-4cda-83b8-92253b564bae"
#   }

#   }
terraform {
  backend "s3" {
    bucket = "dev-test-eks-terraform"
    key    = "01-vpc/terraform.tfstatbe"
    region = "eu-west-1"
  }
}

