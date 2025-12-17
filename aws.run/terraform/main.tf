

terraform {
  backend "s3" {
    # update following as needed
    bucket         = "uts-vaccine-state"
    key            = "Feb2025_nf_Iac"
    region         = "ap-southeast-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.22.0"
      # version = "~> 6.26.0"
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

// create bucket for nextflow scripts and outputs
# Generate a random string to ensure bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for 1000 Genomes data
resource "aws_s3_bucket" "bucket_1000genome" {
  bucket = "1000genome-${random_string.bucket_suffix.result}" # Unique bucket name

  tags = {
    Name        = "1000GenomeData"
    Environment = "Production"
  }
}

