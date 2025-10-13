FROM python:3.9-slim

# Install minimal system dependencies (only procps if needed for process monitoring)
RUN apt-get update && apt-get install -y procps \
    && rm -rf /var/lib/apt/lists/*

# Install Biopython
RUN pip install --no-cache-dir biopython awscli

# Set working directory
WORKDIR /app



