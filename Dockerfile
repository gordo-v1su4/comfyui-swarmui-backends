# Use the same base image as the RunPod template
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /workspace

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HOME=/workspace/huggingface

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    nano \
    unzip \
    rsync \
    build-essential \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies for ComfyUI and SwarmUI
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir \
    xformers \
    triton \
    deepspeed \
    accelerate

# Clone ComfyUI and install its dependencies
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
RUN pip install --no-cache-dir -r ComfyUI/requirements.txt

# Install ComfyUI Manager
RUN cd ComfyUI/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Clone SwarmUI and install its dependencies
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git
RUN cd SwarmUI && chmod +x install.sh && ./install.sh --no-backend

# Copy and set up startup script
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Install additional dependencies for the startup script
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    lsof \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose the necessary ports
EXPOSE 8188 7860

# Command to start the application (can be overridden in Coolify)
CMD ["/workspace/start.sh"]
