scripts="./scripts"
job_name="1000genome-test"

# update aws resource information refer to terraform output
bucket="1000genome-wruhmmui"
job_queue="fargate_job_queue"

# only add nextflow head job definition name here
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
    --container-overrides "{\"command\": [\"/bin/bash\", \"-c\", \"mkdir -p /app/scripts && aws s3 cp s3://${bucket}/scripts /app/scripts/ --recursive && nextflow run /app/scripts/main.nf -profile \\\"awsbatch\\\" -c /app/scripts/nextflow.config -bucket-dir s3://${bucket}/1000genomes/work\"]}"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to submit AWS Batch job."
  exit 1
fi

echo "Job submitted successfully."
