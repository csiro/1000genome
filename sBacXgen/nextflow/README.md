## Execute Nextflow workflow on AWS Batch with Fargate

#### Prerequisites:
- Ensure necessary cloud permission in ~/.aws/credentials. 
- install Git, Terraform, Docker, AWS CLI, and Nextflow on Linux or macOS
 
####  Cloud Deployment
Run Terraform to set up cloud infrastructure. It will access your local Docker daemon, so ensure it is turn on. 
```
  cd nextflow/terraform/
  terraform init
  terraform apply
```
Output Example:
```
  Apply complete! Resources: 20 added, 0 changed, 0 destroyed.
  
  Outputs:
  
  bucket_ouput = "s3://bucket"
  job_difinition_nf = "arn:aws:batch:ap-southeast-2:0...:job-definition/fargate-job-nf_header:11"
  job_difinition_prokka = "arn:aws:batch:ap-southeast-2:0...:job-definition/fargate-job-prokka:11"
  job_difinition_roary = "arn:aws:batch:ap-southeast-2:0...:job-definition/fargate-job-roary:11"
  job_queue = "fargate_job_queue"
```

#### Launch Pipeline on cloud
- Update the Nextflow configuration file with cloud resource details. Example: vi nextflow/pipeline/nextflow.config
```
params {
    ...
    results = "s3://bucket/project/runid/output/"
    input = "s3://<bucketname>/<path>/*.fasta"
}
profiles {
    aws {
        process {
            executor = 'awsbatch' 
        }
        region = 'ap-southeast-2'
    }
    Fargate {
        wave.enabled = false
        process {
            queue = 'fargate_job_queue'
            withLabel: prokka {
                container = 'job-definition://arn:aws:batch:ap-southeast-2:0...:job-definition/fargate-job-prokka:11'
            }
            withLabel: roary {
                container = 'job-definition://arn:aws:batch:ap-southeast-2:0...:job-definition/fargate-job-roary:11'
            }
        }
    }
}
```
- prepare input data, e.g., copy local data to the cloud:
   `aws s3 cp GCF_00000.fasta s3://bucket/test/`

- run NF head job on local PC, e.g.,
  ```
  nextflow run nextflow/pipeline/main.nf -profile aws,Fargate -bucket-dir s3://bucket/work/
  ```
- run NF head job on AWS Batch Fargate environment. See example in the `submit.sh`
  
## Next Steps
Add the configured cloud resources to your web application property file, then deploy the web application. Refer to the   [WebApp ReadMe](https://github.com/DalongHu/project/blob/main/cloud_platform/webApp/backend/README.md) for details.

