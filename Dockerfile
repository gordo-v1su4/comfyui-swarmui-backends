# Use the exact RunPod PyTorch base image as specified in instructions
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set environment variables exactly as RunPod
ENV HF_HOME="/workspace"
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /workspace

# Install system dependencies (psmisc for fuser command)
RUN apt-get update && apt-get install -y \
    psmisc \
    && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI

# Setup ComfyUI
RUN cd /workspace/ComfyUI && \
    git reset --hard && \
    git stash && \
    git pull --force

# Create and activate virtual environment
RUN cd /workspace/ComfyUI && \
    python -m venv venv

# Upgrade pip
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    python -m pip install --upgrade pip

# Install ComfyUI requirements
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install -r requirements.txt

# Uninstall and reinstall torch exactly as RunPod
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip uninstall torch torchvision xformers torchaudio --yes && \
    pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# Install flash attention and optimizations
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl

# Install additional packages
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install insightface && \
    pip install onnxruntime-gpu

# Clone custom nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor && \
    git clone https://github.com/city96/ComfyUI-GGUF

# Update ComfyUI-GGUF
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    git reset --hard && \
    git stash && \
    git pull --force

# Update ComfyUI-Manager
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    git reset --hard && \
    git stash && \
    git pull --force

# Install ReActor
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-ReActor && \
    cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-ReActor && \
    python install.py

# Clone and install Impact Pack
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    cd ComfyUI-Impact-Pack && \
    cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    python install.py

# Install additional pip packages
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install piexif && \
    pip install requests && \
    pip install triton && \
    pip install deepspeed && \
    pip install huggingface_hub hf_transfer && \
    pip install accelerate && \
    pip install diffusers

# Install GGUF requirements
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    pip install -r requirements.txt

# Copy model download scripts if available
COPY Download_Reactor_Models.py* /workspace/
COPY Download_IP_Adapters_Fast.py* /workspace/
COPY Download_Models.py* /workspace/

# Run reactor model download if script exists
RUN if [ -f "/workspace/Download_Reactor_Models.py" ]; then \
        cd /workspace && \
        python Download_Reactor_Models.py || echo "Reactor model download failed, continuing..."; \
    fi

# Create startup script exactly as RunPod
RUN echo '#!/bin/bash\n\
apt update\n\
apt install -y psmisc\n\
fuser -k 3000/tcp 2>/dev/null || true\n\
cd /workspace/ComfyUI/venv\n\
source bin/activate\n\
cd /workspace/ComfyUI\n\
python main.py --listen 0.0.0.0 --port 3000 --use-sage-attention\n\
' > /workspace/start.sh && chmod +x /workspace/start.sh

# Expose the port (using 3000 as per RunPod)
EXPOSE 3000

# Set the command to start ComfyUI
CMD ["/workspace/start.sh"]
