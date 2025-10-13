/****************************************************************************************************************/
#source  = "terraform-aws-modules/lambda/aws//modules/docker-build" not suits our purpose
# above module won't apply tag to docker image respectively
#
# Here we use existing ECR but apply different tags to each image
# refer to https://github.com/terraform-aws-modules/terraform-aws-lambda/tree/v7.20.1/modules/docker-build
# refer to https://registry.terraform.io/providers/davidthor/docker/latest/docs/resources/registry_image
/****************************************************************************************************************/


# set local variable to access ECR
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}
locals {
  # Define a local variable to remove "https://" from the ecr_proxy_endpoint
  clean_image_repo_url = replace(data.aws_ecr_authorization_token.token.proxy_endpoint, "https://", "")
  ecr_image = "${var.ecr_repo_url}:${var.image_tag}"
  docker_path = abspath( "${path.cwd}/${var.docker_file_path}" )
}

# Pull and push the Docker image to the ECR repository using Docker commands
resource "null_resource" "pull_tag_push_image" {
  provisioner "local-exec" {
    command = <<-EOT

      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${local.clean_image_repo_url}

      # Build the Docker image
      docker build --platform linux/amd64 -t ${local.ecr_image}  ${local.docker_path}

      # Push the tagged image to the ECR repository
      docker push  ${local.ecr_image}
    EOT
  }

}

#  Define Job Definitions Using the Outputs
resource "aws_batch_job_definition" "nextflow_job" {

  name        = "fargate-job-${var.image_tag}"
  propagate_tags        = true
  platform_capabilities = ["FARGATE"]
  type        = "container"

  parameters  = {}
  tags = { JobDefinition = var.image_tag }

  container_properties = jsonencode({
      image      = local.ecr_image
      command    = []

      resourceRequirements = [
        {
          type  = "VCPU"
          value = var.vcpu
        },
        {
          type  = "MEMORY"
          value = var.ram
        }
      ]

      fargatePlatformConfiguration = {
        platformVersion = "LATEST"
      }

      jobRoleArn = var.job_role_arn
      executionRoleArn = var.execution_role_arn

      logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.log_group
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = var.image_tag
          }
      }
  })
}


