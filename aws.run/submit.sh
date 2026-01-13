
# update aws resource information refer to terraform output
aws_region=$(terraform -chdir=./terraform output -raw aws_region)
bucket=$(terraform -chdir=./terraform output -raw bucket_output)
job_queue=$(terraform -chdir=./terraform output -raw job_queue)
job_definition_nf=$(terraform -chdir=./terraform output -raw job_name_nf)
job_definition_pca=$(terraform -chdir=./terraform output -raw job_definition_pca)
job_definition_bcftool=$(terraform -chdir=./terraform output -raw job_definition_bcftool)

# experiment job setting
job_name="1000genome-test"
email_to="xu102@csiro.au"

# Generating fresh nextflow.config
sed \
    -e "s|\${EMAIL}|$email_to|g" \
    -e "s|\${AWS_REGION}|$aws_region|g" \
    -e "s|\${AWS_BUCKET}|$bucket|g" \
    -e "s|\${BATCH_QUEUE}|$job_queue|g" \
    -e "s|\${PCA_JOB_DEFINITION}|$job_definition_pca|g" \
    -e "s|\${BCFTOOLS_JOB_DEFINITION}|$job_definition_bcftool|g" \
    scripts/nextflow.config.tmpl > scripts/nextflow.config
echo "Generated fresh nextflow.config"


# Copying scripts to s3://${bucket}/scripts
scripts="./scripts"
aws s3 cp "${scripts}/" "${bucket}/scripts/" --recursive 
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to copy scripts to S3."
  exit 1
fi
echo "Copied scripts to s3 bucket ${bucket}"

# Submit AWS Batch job
echo "Submitting AWS Batch job: ${job_name}..."

aws batch submit-job \
    --job-name "${job_name}" \
    --job-queue "${job_queue}" \
    --job-definition "${job_definition_nf}" \
    --container-overrides "{\"command\": [\"/bin/bash\", \"-c\", \"mkdir -p /app/scripts && aws s3 cp ${bucket}/scripts /app/scripts/ --recursive && nextflow run /app/scripts/main.nf -profile \\\"awsbatch\\\" -c /app/scripts/nextflow.config -bucket-dir ${bucket}/1000genomes/work\"]}"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to submit AWS Batch job."
  exit 1
fi

echo "Job submitted successfully."




