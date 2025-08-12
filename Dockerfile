# Use a standard NVIDIA CUDA base image for better compatibility
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/data/huggingface

# Set up the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3.10 \
    python3-pip \
    python3.10-venv \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Make python3.10 the default python3
RUN ln -sf /usr/bin/python3.10 /usr/bin/python3

# --- ComfyUI Setup ---
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir --upgrade pip

# The requirements.txt file will handle the installation of torch and other dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install ComfyUI Manager
RUN cd custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# --- SwarmUI Setup ---
WORKDIR /app
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git
RUN cd SwarmUI && chmod +x install.sh && ./install.sh --no-backend

# Expose ports
EXPOSE 8188 7860

# Create a startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Set the entrypoint to the startup script
CMD ["/app/start.sh"]