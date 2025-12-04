
resource "aws_batch_compute_environment" "fargate_environment" {
  name = "fargate_environment"
  type                     = "MANAGED"
  service_role         = aws_iam_role.batch_service_role.arn
  depends_on   = [aws_iam_role_policy_attachment.batch_service_policy_attachment]

  compute_resources {
    max_vcpus          = 256
    min_vcpus          = 0
    subnets            = data.aws_subnets.default_public.ids
    security_group_ids = [aws_security_group.fargate_sg.id]
    type               = "FARGATE"
    # Explicitly set network configuration here
    # same as the spot environment default without explicity setting 
    # network_configuration { assign_public_ip = "ENABLED" }
  }


}

resource "aws_batch_compute_environment" "fargate_spot_environment" {
  name = "fargate_spot_environment"
  type                     = "MANAGED"
  service_role             = aws_iam_role.batch_service_role.arn
  depends_on               = [aws_iam_role_policy_attachment.batch_service_policy_attachment]

  compute_resources {
    max_vcpus          = 256
    min_vcpus          = 0
    security_group_ids = [aws_security_group.fargate_sg.id]
    subnets            = data.aws_subnets.default_public.ids
    type               = "FARGATE_SPOT"
  }
  
}

resource "aws_batch_job_queue" "fargate_job_queue" {
  name                 = "fargate_job_queue"
  state                = "ENABLED"
  priority             = 1

  compute_environment_order {
    order                  = 2
    compute_environment    = aws_batch_compute_environment.fargate_environment.arn
  }

  compute_environment_order {
    order                  = 1
    compute_environment    = aws_batch_compute_environment.fargate_spot_environment.arn
  }
}


#########################################################################################
# This role is assumed by the AWS Batch service to manage the compute enfironment
# enables AWS Batch to manage resources such as compute environments, job queues, 
# and jobs, while interacting with services like Amazon ECS, EC2, and CloudWatch Logs.
# it is required in both EC2 and Fargate mode
#########################################################################################

resource "aws_iam_role" "batch_service_role" {
  name = "aws_batch_service_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
        Effect = "Allow",
        Principal = { Service = "batch.amazonaws.com" },
        Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS Managed Policy
resource "aws_iam_role_policy_attachment" "batch_service_policy_attachment" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

