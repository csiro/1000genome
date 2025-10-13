# antigen selection pipeline

## Description

This pipeline is for antigen selecction by using [nextflow](https://www.nextflow.io) in [AWS Batch](https://aws.amazon.com/batch/). It runs [prokka](https://github.com/tseemann/prokka) in parallel, then prepares a collated [roary](https://github.com/sanger-pathogens/Roary) report.




## how to run
Set up all parameters within the configuration file. The default configuration is nextflow.config, you can use the customerized config file with option `-c` on nextflow run command line. 
- run nextflow in Fargate mode from local PC or EC2 with aws cli installed <br>
`nextflow run main.nf -profile aws,Fargate -bucket-dir s3://bucket/nextflow_cache` <br>
- run next flow on your local PC with running docker <br>
`nextflow run main.nf -profile local`

## container
- refer to `docker pull staphb/prokka:latest` 
- refer to docker/ncbi-blast-docker


## db
- wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz



