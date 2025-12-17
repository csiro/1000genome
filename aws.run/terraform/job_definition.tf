
#####################################################################
#  create one ECR to store all docker images with different tag name
#####################################################################
resource "aws_ecr_repository" "repo" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
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
   ecr_repo_url = aws_ecr_repository.repo.repository_url
   docker_file_path = "../scripts/modules/nextflow"
   image_tag = "nf_header"

   # the nextflow head job require "batch:SubmitJob"
   job_role_arn = aws_iam_role.fargate_nf_head_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}

# create fargate job definition for roary
module "job_definition_pca"{
   source = "./modules/fargate-job"
   ecr_repo_url = aws_ecr_repository.repo.repository_url
   docker_file_path = "../scripts/modules/pca"
   image_tag = "pca"
   vcpu = "2"
   ram = "16384"  #16.GB
   
   job_role_arn = aws_iam_role.fargate_job_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}

# create fargate job definition for nextflow head job
module "job_definition_bcftool"{
   source = "./modules/fargate-job"
   ecr_repo_url = aws_ecr_repository.repo.repository_url
   docker_file_path = "../scripts/modules/bcftool"
   image_tag = "bcftool"
   vcpu = "1"
   ram = "2048"  #2.GB
   
   
   job_role_arn = aws_iam_role.fargate_job_role.arn
   execution_role_arn = aws_iam_role.fargate_execution_role.arn
   log_group = aws_cloudwatch_log_group.nextflow_log_group.name
   depends_on = [aws_ecr_repository.repo]
}
