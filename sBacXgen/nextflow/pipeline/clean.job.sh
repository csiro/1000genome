#!/bin/bash

# Set prefix for job definition names
pre="fargate-"

# Ensure AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Error: AWS CLI is not configured properly. Please run 'aws configure' or set AWS credentials." >&2
    exit 1
fi

# Query active job definitions starting with the prefix
echo "Querying job definitions starting with '$pre'..."
job_definitions=$(aws batch describe-job-definitions --status ACTIVE \
    --query "jobDefinitions[?starts_with(jobDefinitionName, '$pre')].jobDefinitionArn" \
    --output json | jq -r '.[]' 2>/dev/null)

# Check if job_definitions is empty
if [ -z "$job_definitions" ]; then
    echo "No active job definitions found starting with '$pre'." >&2
    exit 1
fi

# Print the job definition ARNs
echo "Found job definitions:"
echo "$job_definitions"

while IFS= read -r arn; do
    if [ -n "$arn" ]; then
        echo "Deregistering $arn..."
        aws batch deregister-job-definition --job-definition "$arn"
        if [ $? -eq 0 ]; then
            echo "Successfully deregistered $arn"
        else
            echo "Failed to deregister $arn"
        fi
    fi
done <<< "$job_definitions"

echo "Deregistration process complete."
