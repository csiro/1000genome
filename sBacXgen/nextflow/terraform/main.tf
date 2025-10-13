

terraform {
  backend "s3" {
    # update following as needed
    bucket         = "uts-vaccine-state"
    key            = "Feb2025_nf_Iac"
    region         = "ap-southeast-2"
    # dynamodb_table = "uts-vaccine-states-table"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.22.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
    region         = var.region
}


#################################################################
# configuration
#################################################################

data "aws_ecr_authorization_token" "token" {}
provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

#  create bucket for nextflow scripts and outputs
# Generate a random string to ensure bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for input, output and script
resource "aws_s3_bucket" "bucket_project" {
  bucket = "${var.project}-${random_string.bucket_suffix.result}" # Unique bucket name

  tags = {
    Name        = var.project
    Environment = var.environment
  }
}

#################################################################
# output
#################################################################

output "job_queue" {
  description = "The job queu name"
  value       = aws_batch_job_queue.fargate_job_queue.name
}

output "job_difinition_nf" {
  description = "The job difinition arn of nexflow head job"
  value       = module.job_definition_nf.job_id
}

output "job_difinition_prokka" {
  description = "The job difinition arn of prokka"
  value       = module.job_definition_prokka.job_id
}

output "job_difinition_roary" {
  description = "The job difinition arn of roary"
  value       = module.job_definition_roary.job_id
}

output "bucket_ouput" {
  description = "The job difinition arn of roary"
  value       = "s3://${aws_s3_bucket.bucket_project.bucket}"
}
