# Nextflow Pipeline on AWS Fargate
A Nextflow pipeline is proposed to Examine genomic variation across populations with AWS. Here, both Nextflow head and task jobs are running on AWS Fargate, leveraging Spot instances, and automating infrastructure with Terraform, our approach overcomes the scalability, cost, and speed limitations of prior methods.

## AWS Cloud Infrasture
The folder named terraform provides the template to set up cloud infrastructure. 
- step 1: Prerequisites 
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

   - set up terraform state bucket refer to https://developer.hashicorp.com/terraform/language/backend/s3 <BR>
    you can use you exiting bucket or create a new bucket through AWS console, update the bucket information in backend session. 
	```
	# aws.run/terraform/main.tf
     	terraform {
	  backend "s3" {
    		# update following as needed
		bucket         = "you-state-bucket-name"
    		key            = "you-key-name"
    		region         = "you-state-bucket-region"
	
  		}
	}
	
	```
- step 2: Run Terraform to set up cloud infrastructure.  It will access your local Docker daemon, so ensure it is turn on.
  ```
  cd ./aws.run/terraform
  terraform init
  terraform apply
  ```
  it will output the resource information which will be used in the step3. Below is an example
  ```
	Outputs:

	bucket_ouput = "s3://1000genome-wruhmmui"
	job_definition_bcftool = "arn:aws:batch:us-east-1:...:job-definition/fargate-job-bcftool:6"
	job_definition_nf = "arn:aws:batch:us-east-1:...:job-definition/fargate-job-nf_header:5"
	job_definition_pca = "arn:aws:batch:us-east-1:...:job-definition/fargate-job-pca:6"
	job_queue = "fargate_job_queue"
	
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
