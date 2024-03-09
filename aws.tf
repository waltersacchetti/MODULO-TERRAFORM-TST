module "aws" {
  source = "./module"
  aws    = local.pre.aws
}
