FROM mambaorg/micromamba:latest AS builder

# Create the conda environment and install aws cli
# Initialize the shell and activate the environment, then install awsci
RUN micromamba create -y -n awscli python=3.8 && \
     eval "$(micromamba shell hook --shell bash)" && \
    micromamba activate awscli && \
    micromamba install -c conda-forge  -y awscli

# stage 2
FROM nextflow/nextflow:24.10.4

# keep path same due to The shebang line in the aws script points to below location
COPY --from=builder /opt/conda/envs/awscli /opt/conda/envs/awscli
ENV PATH=/opt/conda/envs/awscli/bin:$PATH

# Container Startup
CMD [ "/bin/bash", "-c", "aws --version && nextflow -version" ]
