# Use the same base image as the RunPod template for consistency
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /workspace

# Install required packages first
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and extract the zip file in one layer to reduce image size
COPY Comfy_UI_V45.zip /tmp/
RUN cd /workspace && \
    unzip -q /tmp/Comfy_UI_V45.zip && \
    rm /tmp/Comfy_UI_V45.zip && \
    ls -la /workspace/

# Set HF_HOME environment variable as per RunPod instructions
ENV HF_HOME="/workspace"

# Make the installation script executable and run it with proper environment
RUN if [ -f "/workspace/RunPod_Install.sh" ]; then \
        chmod +x /workspace/RunPod_Install.sh && \
        export HF_HOME="/workspace" && \
        export HF_HUB_ENABLE_HF_TRANSFER=1 && \
        bash -c "/workspace/RunPod_Install.sh"; \
    else \
        echo "RunPod_Install.sh not found, listing files:" && \
        find /workspace -name "*.sh" -type f; \
    fi

# 5. Copy the startup script into the container
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Expose the port for ComfyUI backend
EXPOSE 8188

# Set the command to our startup script
CMD ["/workspace/start.sh"]