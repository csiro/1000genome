
#####################################################################
#  create one ECR to store all docker images with different tag name
#  use existing repo if already exists
#####################################################################

# Attempt to fetch the existing ECR repository
data "aws_ecr_repository" "repo" {
  name = var.project
}

# Conditionally create a new ECR repository if the existing one doesn't exist
resource "aws_ecr_repository" "repo" {
  count = length(data.aws_ecr_repository.repo.arn) == 0 ? 1 : 0
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Define a unified repository URL
locals {
  repo_exists          = length(data.aws_ecr_repository.repo.arn) > 0
  clean_image_repo_url = local.repo_exists ? data.aws_ecr_repository.repo.repository_url : aws_ecr_repository.repo[0].repository_url
}

resource "aws_cloudwatch_log_group" "nextflow_log_group" {
  name              = "/aws/batch/nextflow"
  retention_in_days = 30
}
#####################################################################
#  list all fargate job definition for each nextflow tasks below:
#####################################################################


# create fargate job definition for nextflow head job from Dockerfile
module "job_definition_nf"{
   source = "./modules/fargate-job"
   # eg. 123456789012.dkr.ecr.us-west-2.amazonaws.com/${var.project}
   ecr_repo_url = local.clean_image_repo_url
   docker_file_path = "./modules/nextflow"
   image_tag = "nf_header"

   # the nextflow head job require "batch:SubmitJob"
   job_role_arn = aws_iam_role.fargate_nf_head_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}

# create fargate job definition for roary
module "job_definition_roary"{
   source = "./modules/fargate-job"
   ecr_repo_url = local.clean_image_repo_url
   docker_file_path = "./modules/roary"
   image_tag = "roary"
   vcpu = "8"
   ram = "16384"  #16.GB
   
   job_role_arn = aws_iam_role.fargate_job_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}

# create fargate job definition for nextflow head job
module "job_definition_prokka"{
   source = "./modules/fargate-job"
   ecr_repo_url = local.clean_image_repo_url
   docker_file_path = "./modules/prokka"
   image_tag = "prokka"
   
   job_role_arn = aws_iam_role.fargate_job_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}
