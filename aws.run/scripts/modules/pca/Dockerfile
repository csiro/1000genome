FROM python:3.9-slim

# Install system dependencies (procps provides ps command for NF to track process)
RUN apt-get update && apt-get install -y libglib2.0-0 libsm6 libxext6  libxrender-dev procps  \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages including awscli on cloud
RUN pip install --no-cache-dir -U pandas scikit-learn plotly "kaleido==0.2.1" awscli

# Set working directory (optional)
WORKDIR /app

# docker build -t 1000genome/pca-python:3.9 .
# docker push 1000genome/pca-python:3.9 20020811/pca-python:3.9
