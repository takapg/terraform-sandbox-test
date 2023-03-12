locals {
  product  = "sandbox"
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "s3"

  config = {
    region               = "ap-northeast-1"
    bucket               = "localstack-tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    encrypt              = true
    bucket_sse_algorithm = "AES256"

    # LocalStack
    force_path_style            = true
    endpoint                    = "http://localstack:4566"
    skip_credentials_validation = true

    # NOT recommended for production code
    skip_bucket_root_access  = true
    skip_bucket_enforced_tls = true
  }

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "version" {
  path      = "_version.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}
EOF
}

generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Product   = "${local.product}"
      Env       = "${local.env_vars.locals.env}"
      Terraform = true
    }
  }

  # LocalStack
  s3_use_path_style = true
}
EOF
}

terraform {
  extra_arguments "plan" {
    commands  = ["plan"]
    arguments = ["-lock=false"]
  }
}

retryable_errors = [
  "(?s).*exit status 126.*"
]
