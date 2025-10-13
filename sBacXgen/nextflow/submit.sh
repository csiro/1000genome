scripts="./pipeline"
bucket="s3://rnahd1-gb9vc1ly"
job_queue="fargate_job_queue"
job_name="test"
job_definition="fargate-job-nf_header"

# Copy scripts to S3
aws s3 cp ${scripts}/ s3://${bucket}/scripts/ --recursive 
echo "Copying scripts to s3://${bucket}/scripts/..."
aws s3 cp "${scripts}/" "s3://${bucket}/scripts/" --recursive
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to copy scripts to S3."
  exit 1
fi

# Submit AWS Batch job
echo "Submitting AWS Batch job: ${job_name}..."

aws batch submit-job \
    --job-name "${job_name}" \
    --job-queue "${job_queue}" \
    --job-definition "${job_definition}" \
    --container-overrides "{\"command\": [\"/bin/bash\", \"-c\", \"mkdir -p /app/scripts && aws s3 cp s3://${bucket}/scripts /app/scripts/ --recursive && nextflow run /app/scripts/main.nf -profile \\\"aws,Batch\\\" -c /app/scripts/nextflow.config -bucket-dir s3://${bucket}/work\"]}"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to submit AWS Batch job."
  exit 1
fi

echo "Job submitted successfully."
