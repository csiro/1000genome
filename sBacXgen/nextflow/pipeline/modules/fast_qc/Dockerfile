# must use `docker build --platform linux/amd64 ...` otherwise build fail on my mac
FROM mambaorg/micromamba:latest AS builder

# Create the conda environment and install aws cli
# Initialize the shell and activate the environment, then install awsci
RUN micromamba create -y -n awscli python=3.8 && \
     eval "$(micromamba shell hook --shell bash)" && \
    micromamba activate awscli && \
    micromamba install -c conda-forge  -y awscli

# Stage 2: reduced image size from 1.
FROM staphb/fastqc:0.12.1

COPY --from=builder /opt/conda/envs/awscli /opt/conda/envs/awscli

# Set the path for conda environment
ENV PATH=/opt/conda/envs/awscli/bin:$PATH

# Container Startup
CMD [ "/bin/bash", "-c", "aws --version && fastqc -h" ]
