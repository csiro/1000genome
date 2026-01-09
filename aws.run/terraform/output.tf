#################################################################
# output
#################################################################

output "job_queue" {
  description = "The job queu name"
  value       = aws_batch_job_queue.fargate_job_queue.name
}

output "job_definition_nf" {
  description = "The job definition arn of nexflow head job"
  value       = module.job_definition_nf.job_id
}

output "job_definition_pca" {
  description = "The job definition arn of pca"
  value       = module.job_definition_pca.job_id
}

output "job_definition_bcftool" {
  description = "The job definition arn of bcftool"
  value       = module.job_definition_bcftool.job_id
}

output "bucket_output" {
  description = "The bucket to store output"
  value       = "s3://${aws_s3_bucket.bucket_1000genome.bucket}"
}
