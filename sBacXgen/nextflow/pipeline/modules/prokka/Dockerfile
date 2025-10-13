# must use `docker build --platform linux/amd64 ...` otherwise build fail on my mac
FROM mambaorg/micromamba:latest AS builder

# Switch to the root user; otherwise can't run apt-get
USER root

# Create the conda environment and install prokka and aws cli
# Initialize the shell and activate the environment, then install prokka
RUN micromamba create -y -n prokka python=3.8 && \
     eval "$(micromamba shell hook --shell bash)" && \
    micromamba activate prokka && \
    micromamba install -y -c bioconda -c conda-forge prokka && \
    micromamba install -c conda-forge  -y awscli


# Stage 2: reduced image size from 3.43G (stage1) to 988MB
FROM ubuntu:latest

COPY --from=builder /opt/conda/envs/prokka /opt/conda/envs/prokka

# Set the path for conda environment
ENV PATH=/opt/conda/envs/prokka/bin:$PATH

#unable to start container process: exec: "rm -rf /tmp/* /var/tmp/*": stat rm -rf /tmp/* 
# clean up temp files at runtime
# ENTRYPOINT [ "rm -rf /tmp/* /var/tmp/*" ]

# Container Startup
CMD [ "/bin/bash", "-c", "aws --version && prokka -h" ]





