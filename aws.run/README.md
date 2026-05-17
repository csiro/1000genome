# Serverless Nextflow
A Nextflow pipeline is proposed to Examine genomic variation across populations with AWS. Here, both Nextflow head and task jobs are running on AWS Fargate, leveraging Spot instances, and automating infrastructure with Terraform, our approach overcomes the scalability, cost, and speed limitations of prior methods. 

## Solution Overview
The following diagram illustrates the how we orchestrate and run genomic variant analyses as Nextflow jobs using AWS Fargate, AWS Batch, and Amazon S3.

| <img src="aws.solution.jpg" width="600" height="600"> |

## Deployment
Here, we will demonstrate how to execute the source code from our GitHub repo to AWS cloud. 

### Prerequisites 
- Git
- Docker
- Terraform
- AWS CLI
- AWS credentials

### Instructions
  
- Create a Terraform state s3 bucket
  
	Run the command `aws s3 mb s3:://<state_bucket_name>` to create the Terraform state S3 bucket, you can use any globally-unique valid S3 bucket name. This bucket will store the state of all the AWS resources that will be provisioned by Terraform.

- Update the state bucket name in aws.run/terraform/main.tf
  ```
  terraform {
  	backend "s3" {
  		bucket = <state_bucket_name>
  		...
  ```

- Run Terraform scripts while your local Docker deamon is running
  ```
  git clone https://github.com/csiro/1000genome.git
  cd aws.run/terraform
  terraform init
  terraform apply
  ```

- Run the aws.run/submit.sh
  ```
  cd aws.run && bash submit.sh
  ```
	This will perform the solution overview workflow and copy the scripts needed to run each task to S3 bucket and then launch the head node AWS Batch job, which will subsequently launch new downstream AWS Batch jobs as needed.

- Cleanup – Delete the deployed AWS resources when your experimentation is complete. 
	```
	cd aws.run/terraform 
	terraform destroy 
	```
	Here, the contents of the job S3 bucket and the ECR repository must be manually deleted before Terraform can delete all deployed resources. Otherwise, it will fail on non-empty resources, and output the warning message.





## AWS Infrastructure Summary
This Terraform configuration will provision the following resources:

| Category                    | Resource Name                          | Type / Details                                      | Purpose |
|-----------------------------|----------------------------------------|-----------------------------------------------------|---------|
| **VPC**                     | Default VPC                            | `vpc-0c5xxx` (us-east-1)                | Uses existing default VPC |
| **Subnets**                 | Default Public Subnets                 | 6 subnets                                           | Used by AWS Batch Fargate tasks |
| **Security Group**          | `batch-fargate-sg`                     | All outbound allowed                                | Security group for Fargate tasks |
| **ECR Repository**          | `1000genome`                           | Mutable tags + image scanning enabled               | Stores Docker images for Nextflow jobs |
| **S3 Bucket**               | `1000genome-<random-suffix>`           | Production bucket                                   | Input / Output data storage for 1000 Genomes pipeline |
| **AWS Batch - Compute Env** | `fargate_environment`                  | Fargate (On-Demand)                                 | Primary compute environment |
| **AWS Batch - Compute Env** | `fargate_spot_environment`             | Fargate Spot                                        | Cost-optimized fallback |
| **AWS Batch - Job Queue**   | `fargate_job_queue`                    | Priority queue                                      | Submits jobs to Fargate environments |
| **IAM Roles**               | `aws_batch_service_role`               | AWS Batch Service Role                              | Required by AWS Batch |
| **IAM Roles**               | `fargate_execution_role`               | ECS Task Execution Role                             | Image pulling & logging |
| **IAM Roles**               | `fargate_job_role`                     | Job Role + AmazonS3FullAccess                       | Runtime permissions for jobs |
| **IAM Roles**               | `fargate_nf_head_role`                 | Nextflow Head Job Role                              | Special role for Nextflow head job |
| **CloudWatch Logs**         | `/aws/batch/nextflow`                  | 30 days retention                                   | Container and pipeline logs |
| **Batch Job Definitions**   | `fargate-job-bcftool`<br>`fargate-job-nf_header`<br>`fargate-job-pca` | Container job definitions | Reusable templates for pipeline steps |

Here The AWS Batch, job definition and IAM roles are free, you only pay for the vCPUs and memory consumed by Fargate tasks. The total estimated cost of running this use-case is $1.32 (or $0.49 with Spot pricing at a 70% discount) with an on-going monthly cost of less than $0.10 (for S3 and ECR storage). Other potential fees, such as CloudWatch Logs, cross-region S3 data transfer, and ECR pull costs were negligible, because all resource were deployed in the same AWS region and the log volumes were small 


## run nextflow in aws

- update the parameter value within configuration file "./scripts/nextflow.config".
  - "chunk_size": the maximum sample number with each group during "SPLIT_SAMPLE" task
  - "rand_fraction" : the portion of variants to be randomly selected during "RAND_SELECT" task
  - "maf_interval" select variants fallen in the specified interval range.  
  - "container": the task job_definition refer to step 3 of AWS Cloud Infrastructure.   
 
- run NF job to cloud, refer to submit.sh
  ```
  aws batch submit-job \
    --job-name "${job_name}" \
    --job-queue "${job_queue}" \
    --job-definition "${job_definition_nf}" \
    --container-overrides "{\"command\": [\"/bin/bash\", \"-c\", \"mkdir -p /app/scripts && aws s3 cp 		${bucket}/scripts /app/scripts/ --recursive && nextflow run /app/scripts/main.nf -profile \\\"awsbatch\\\" -c /app/scripts/nextflow.config -bucket-dir ${bucket}/1000genomes/work\"]}"
	```
 
