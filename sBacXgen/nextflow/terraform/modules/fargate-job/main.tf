
#################################################################
# inputs
#################################################################

variable "ecr_repo_url" {
  description = "url of ECR repository to use"
  type        = string
  default     = null
}

variable "docker_file_path" {
  description = "Path to folder containing Dockerfile"
  type        = string
  default     = null
}

variable "image_tag" {
  description = "it is compulsary to provide tag for each docker image, hence we can allow multi images within one ECR repo."
  type        = string
  default     = null
}


variable "job_role_arn" {
  description = "The ARN of the IAM role to use for the job"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the IAM role to use for the batch server"
  type        = string
}

variable "log_group" {
  description = "pass the cloudwatch log group name to store fargate job logs"
  type		= string
  default       = "aws/batch/log"
}

variable "vcpu" {
  description = "VCPU value for job definition"
  type		= string
  default       = "2"
}

variable "ram" {
  description = "MEMORY  value for job definition, eg 4096 for 4G"
  type          = string
  default       = "4096"
}


#################################################################
# outptus
#################################################################

output "job_id" {
  description = "The ID of job definition"
  value       = aws_batch_job_definition.nextflow_job.id
}

output "job_name" {
  description = "The name of job definition"
  value       = aws_batch_job_definition.nextflow_job.name
}

#################################################################
# configuration
#################################################################

terraform {
  # default provider is hashicorp/docker; have to explictly configue it.
  required_providers {
    aws = {  source  = "hashicorp/aws" }
    docker = { source  = "kreuzwerker/docker" }
  }
}

