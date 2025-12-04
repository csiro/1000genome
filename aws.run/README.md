# Nextflow Pipeline on AWS Fargate
A Nextflow pipeline is proposed to Examine genomic variation across populations with AWS. Here, both Nextflow head and task jobs are running on AWS Fargate, leveraging Spot instances, and automating infrastructure with Terraform, our approach overcomes the scalability, cost, and speed limitations of prior methods.

## AWS Cloud Infrasture
The folder named terraform provides the template to set up cloud infrastructure. 
- step 1: prequests
  - set up AWS cloud credential in your local PC. 
  ```
  # eg. less ~/.aws/config 
  [default]
    region = us-east-1 
    output = json

  # eg. less ~/.aws/credentials 
  [default]
    aws_access_key_id=ASIAQT...X
    aws_secret_access_key=1mSq9i0+Vcr...A/u
    aws_session_token=IQoJ/...=
  ```
  - terraform state bucket has to be set up first refer to https://developer.hashicorp.com/terraform/language/backend/s3
    
- step 2: Run Terraform to set up cloud infrastructure.  It will access your local Docker daemon, so ensure it is turn on.
  
  ```
  cd ./aws.run/terraform
  terraform init
  terraform apply
  ```
- step 3: now you can get aws resource through AWS console or terraform command. eg.
  - job_definition arn to launch docker container running PCA and bcftool, refer to "scripts/nextflow.config"
  - name of your private bucket, job_queue and Nextflow head job_definition, refer to "submit.sh"
    
## Nextflow Pipeline

- update the parameter value within configuration file "./scripts/nextflow.config".
  - "chunk_size": the maximum sample number with each group during "SPLIT_SAMPLE" task
  - "rand_fraction" : the portion of variants to be randomly selected during "RAND_SELECT" task
  - "maf_interval" select variants fallen in the specified interval range.  
  - "container": the task job_definition refer to step 3 of AWS Cloud Infrastructure.   
 
- Submit Nextflow to cloud
  - update "submit.sh" following the step3 of  AWS Cloud Infrastructure. Here the Fargate cluster, docker image are already configured within job-queue and job-definition during terraform deployment. 
  - run `bash ./submit.sh`: it copys the nextflow scripts including configuration file to s3; and then submit Nextflow head job to aws batch. 
