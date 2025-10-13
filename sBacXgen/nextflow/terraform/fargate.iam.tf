# this data block of assume role policy is attached to many roles
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

####################################################################
# This role is assumed by the container running the job, 
# any extra permission beyond execution role to each job tasks
# it is better to create job roles for different job task respectively
# due to our job task requires similar permission, we only create one here 
####################################################################
resource "aws_iam_role" "fargate_job_role" {
  name = "fargate_task_job_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

# Attach managed policies for S3 full access and ECS task
resource "aws_iam_role_policy_attachment" "fargate_job_policy_attachment" {
  role       = aws_iam_role.fargate_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

####################################################################
# task role to launch nextflow header job on job queue
# it requries extra permission like batch:SubmitJob
####################################################################
resource "aws_iam_role" "fargate_nf_head_role" {
  name = "fargate_nf_head_job_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

# Attach managed policies for S3 full access and ECS task
resource "aws_iam_role_policy_attachment" "fargate_nf_head_policy_attachment" {
  role       = aws_iam_role.fargate_nf_head_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "fargate_nf_head_policy" {
  name   = "fargate_nf_head_job_policy"
  role       = aws_iam_role.fargate_nf_head_role.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
	  "batch:SubmitJob",
	  "batch:DescribeJobs",
	"batch:DescribeJobQueues",
	"batch:CancelJob",
	"batch:ListJobs",
	"batch:DescribeComputeEnvironments",
	"batch:TerminateJob",
	"batch:RegisterJobDefinition",
	"batch:DescribeJobDefinitions",
          "kms:Decrypt"
        ],
        "Resource": "*"
    }]
  })
}


#########################################################################################
# This role is assumed by the AWS ECS service to manage the job.
# the execution role can be essentially used as a default role for any of the tasks.
#########################################################################################
resource "aws_iam_role" "fargate_execution_role" {
  name = "fargate_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

# Attach managed policies for S3 full access, ECS task, ECR full access, and CloudWatch Logs full access
resource "aws_iam_role_policy_attachment" "fargate_execution_policy_attachment" {
  role       = aws_iam_role.fargate_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

