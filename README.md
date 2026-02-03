 # Welcome to Our "Get Started with Nextflow" Tutorial!
Hi everyone! I am a bioinformatics software engineer, and I’m delighted to share how Nextflow can transform the way you build and run bioinformatic pipelines. My goal is to encourage you to create pipelines in Nextflow, and I'll help you take them to the cloud for scalable, robust execution.

## Backgroud 
<Details>
 
### Why Nextflow?
Nextflow is becoming incredibly popular because it simplifies the development of bioinformatic pipelines. it replaces messy, hard-to-maintain Bash, Python, or Perl scripts with a structured and scalable framework.  with Nextflow, you can:
- Write cleaner, more organized pipelines
- Run your pipelines on your laptop, a cluster, or the cloud with minimal conversion
- Automate complex workflows with ease

### Complexity  Concerns
Yes, Nextflow is powerful, with lots of features and plugins! If you've browsed Nextflow code on GitHub, you might have noticed they can look intimidating. This complexity can scare researchers away from adopting Nextflow. <BR>
But don't worry! Nextflow becomes simple when you understanding its basic concepts. I've gathered beginner-friendly examples, documentation, and tutorials to help you get started. My mission is to guide you through creating a Nextflow pipeline, running it, and customizing it. Once you're ready, I'll help you deploy it on the cloud for maximum scalability.

</Details>

## NextFlow Core Concepts
This outline introduces its core concepts - processes and channels, along with other key features to help you get started.

### Processes and Channels 
<Details>
 
the relationship for [Processes(tasks) and Channels (joints of tasks)](https://training.nextflow.io/2.0/basic_training/intro/#processes-and-channels) is illustrated here. Let's see a simple Nextflow pipeline example: [Hello world code](https://training.nextflow.io/2.0/basic_training/intro/#nextflow-code), and a Directed Acyclic Graph [DAG-like format](https://training.nextflow.io/2.0/basic_training/intro/#in-dag-like-format).   
- [Processes](https://www.nextflow.io/docs/latest/process.html#): Represent individual tasks or steps in a pipeline (e.g., running a script or tool).
  - [inputs types](https://www.nextflow.io/docs/latest/process.html#inputs):
    - val: Simple values (e.g., strings, numbers).
    - path: Files or directories (staged into the process’s working directory).
    - stdin, tuple, env etc
  - [outputs types](https://www.nextflow.io/docs/latest/process.html#outputs)
    - similar to inputs (e.g., val, path, stdout).
    - Use the emit option to name outputs for easier access in workflows (e.g., emit: result).
  - [script](https://www.nextflow.io/docs/latest/process.html#script) 
    - By default, scripts are written in Bash (using triple quotes ''' or double quotes """ for multi-line strings).
    - Supports [other scripting language](https://www.nextflow.io/docs/latest/process.html#scripts-a-la-carte) like Python, Perl, or R.
- [Channels](https://www.nextflow.io/docs/latest/channel.html) act as the "pipes" that connect processes by passing data between them. 
  - They enable asynchronous and parallel execution, making pipelines efficient.
  - Creating Channels:
    - For simple values: Channel.of('Hello', 'World') (emits each value separately).
    - For files: Channel.fromPath('/data/some/bigfile.txt') (emits file paths).
    - For lists: Channel.of(['Hello', 'World']).flatten() (emits each item separately).
    - For a single collection: Channel.of(1, 2, 3, 4).collect() (emits [1, 2, 3, 4] as one item).
  - Operating on Channels:
    - Use operators like .flatten(), .collect(), .map(), or .view() to manipulate data.
    - Focus on what channels do (pass data) rather than their type (queue or value).
  - Key Rule: Always pass data to processes via channels, not raw values.
  - NF Implicitly convert data to a channel for each mode. eg. <Details>
    ```
      process alignSequences {
        input:
          path seq
          each mode
      
        output:
          path 'result'
      
        script:
        """
          t_coffee -in $seq -mode $mode > result
        """
      }
    
      workflow {
        sequences = Channel.fromPath('*.fa')
        methods = ['regular', 'espresso', 'psicoffee']
      
        alignSequences(sequences, methods)
        alignSequences.out.view() // Shows 6 result files
      }
    ```
    </Details>

  - [some channel manipulation examples](https://nextflow-io.github.io/nf-schema/latest/samplesheets/examples/)

</Details>

### Other Concepts
<Details>
 
- [Workflows](https://training.nextflow.io/latest/hello_nextflow/03_hello_workflow/): Combine processes into reusable workflows with DSL2 for cleaner, more organized pipelines.
- [Modules](https://training.nextflow.io/latest/hello_nextflow/04_hello_modules/): Reuse processes across pipelines using Nextflow modules or DSL2, enabling modularity and collaboration.
- [Configuration](https://training.nextflow.io/latest/hello_nextflow/06_hello_config/): Customize pipeline behavior (e.g., memory, CPUs, or queue settings) in the nextflow.config file.
- Scripting language: Nextflow automatically imports certain [Groovy and Java classes](https://www.nextflow.io/docs/latest/reference/stdlib.html#groovy-and-java-classes), allowing direct use in scripts. For example: params { timestamp = (new Date()).getTime() } (from [youtube example](https://www.youtube.com/watch?v=0EZ1EFknEL8&t=8s)).
  
</Details>

### Compute environment
<Details>
 
- [Execution Environments](): local, HPC, Cloud, Containers, Conda. Configure the execution environment in the nextflow.config file.
- [containers](https://training.nextflow.io/latest/hello_nextflow/05_hello_containers/): There are many container image are ready to call it before create your own one. eg. "staphb/bcftools:1.21"
  
</Details>
  
### Command example 
<Details>
 
- `nextflow run test.nf`
- `nextflow run test.nf -with-dag flowchart.png`
- `nextflow run main.nf -profile "awsbatch" -c /app/scripts/nextflow.config -bucket-dir s3://${bucket}/1000genomes/work`
  
</Details>

# Let’s Get Started with "1000genome with AWS Fargate "!
- Start your own Nextflow pipeline by following the [single-sample implementation tutorial](https://training.nextflow.io/latest/nf4_science/rnaseq/02_single-sample/#1-write-a-single-stage-workflow-that-runs-the-initial-qc).
- [Examine genomic variation across populations with AWS](https://aws.amazon.com/blogs/industries/examine-genomic-variation-across-populations-with-aws/)
- The Nextflow pipeline in the local.run folder is ready to run on your local PC with Docker installed.
- The Nextflow pipeline in the aws.run folder is configured to run on AWS Fargate with Terraform deployment.

### Step by Step On Nextflow Journey
<Details>
Let's make this fun and hands-on! Here's how we'll get started:
 
- installation: Bash, Java, NextFlow, Docker, Git etc
- Gather the documents: recommend to use [Full Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html) as dictionary for beginner.
- Learn the Basics: go through the basic training of [Hello Nextflow](https://training.nextflow.io/latest/hello_nextflow/) to understand the core concepts of Nextflow, like processes, channels, and workflows.
- Get Hands-On: Write your first Nextflow pipeline to solve a real bioinformatics problem.
- Scale to the Cloud: Extend your pipeline to run on cloud infrastructure for faster, more robust execution.

By the end, you’ll have a working pipeline and the confidence to build more. I’ll provide the tools and support to make your pipelines cloud-ready.
</Details>

### Container Practice
<Details>
 
- rm local bcftools: eg. `which bcftools; mv /opt/homebrew/bin/bcftools /opt/homebrew/bin/bcftools.bk`
- check docker deamon is on: eg. `nextflow run hello -with-docker`
- set on nextflow.config: `docker.enabled=true` and `runOptions = "--platform linux/amd64"` if on mac
- for customize Dockerfile, you have to turn on local docker deamon and  login dockerHub, and then build push image to your public/private repo
  - build your local image. eg. `docker build -t 1000genome/pca-python:3.9 .`
  - push to dockerhub. eg. `docker tag 1000genome/pca-python:3.9 <your_dockerhub_username>/pca-python:3.9; docker push <your_dockerhub_username>/pca-python:3.9`
</Details>
   
### AWS practice
- [Nextflow on AWS](https://github.com/nextflow-io/nextflow/blob/master/docs/aws.md)
- [Nextflow with AWS Fargate](https://seqera.io/blog/seqera-and-aws-fargate/)
