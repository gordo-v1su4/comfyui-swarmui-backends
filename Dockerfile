# Use Ubuntu base image to avoid Docker layer corruption issues
# This provides a more stable foundation than the problematic PyTorch images
FROM ubuntu:22.04

# Set environment variables for HuggingFace and optimization
ENV HF_HOME="/workspace"
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /workspace

# Install system dependencies and Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    curl \
    wget \
    unzip \
    psmisc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Copy the ComfyUI zip file and extract it
COPY Comfy_UI_V45.zip /tmp/
RUN cd /workspace && \
    unzip -q /tmp/Comfy_UI_V45.zip && \
    rm /tmp/Comfy_UI_V45.zip

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI && \
    cd /workspace/ComfyUI && \
    git reset --hard && \
    git stash && \
    git pull --force

# Create and activate virtual environment, upgrade pip
RUN cd /workspace/ComfyUI && \
    python -m venv venv && \
    . venv/bin/activate && \
    python -m pip install --upgrade pip

# Install PyTorch first (following RunPod V45 specifications)
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# Install ComfyUI requirements
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install -r requirements.txt

# Install optimized packages (RunPod V45 optimizations)
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl || echo "Flash attention install failed, continuing..." && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl || echo "SageAttention install failed, continuing..." && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl || echo "XFormers install failed, continuing..."

# Install additional required packages
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install insightface onnxruntime-gpu requests piexif huggingface_hub hf_transfer accelerate diffusers && \
    pip install triton || echo "Triton install failed, continuing..." && \
    pip install deepspeed || echo "DeepSpeed install failed, continuing..."

# Clone and setup custom nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack

# Setup ComfyUI-GGUF
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    git reset --hard && \
    git stash && \
    git pull --force && \
    cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd custom_nodes/ComfyUI-GGUF && \
    pip install -r requirements.txt || echo "GGUF requirements install failed, continuing..."

# Setup ComfyUI-Manager
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    git reset --hard && \
    git stash && \
    git pull --force

# Setup ComfyUI-ReActor
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd custom_nodes/ComfyUI-ReActor && \
    python install.py || echo "ReActor install failed, continuing..."

# Setup ComfyUI-Impact-Pack
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd custom_nodes/ComfyUI-Impact-Pack && \
    python install.py || echo "Impact-Pack install failed, continuing..."

# Copy model download scripts and run if available
RUN if [ -f "/workspace/Download_Reactor_Models.py" ]; then \
        cd /workspace/ComfyUI && \
        . venv/bin/activate && \
        cd /workspace && \
        python Download_Reactor_Models.py || echo "Model download failed, continuing..."; \
    fi

# Copy startup script and make it executable
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Create a SwarmUI-compatible startup script
RUN echo '#!/bin/bash\n\
cd /workspace/ComfyUI\n\
source venv/bin/activate\n\
export HF_HOME="/workspace"\n\
export HF_HUB_ENABLE_HF_TRANSFER=1\n\
export CUDA_VISIBLE_DEVICES=0\n\
fuser -k 8188/tcp 2>/dev/null || true\n\
echo "Starting ComfyUI for SwarmUI backend..."\n\
python main.py --listen 0.0.0.0 --port 8188 --use-sage-attention --gpu-only --disable-xformers --disable-opt-split-attention\n\
' > /workspace/start_comfyui.sh && chmod +x /workspace/start_comfyui.sh

# Expose the port for ComfyUI backend (SwarmUI compatible)
EXPOSE 8188

# Add healthcheck for SwarmUI integration
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:8188/system_stats || exit 1

# Set the command to start ComfyUI for SwarmUI backend
CMD ["/workspace/start_comfyui.sh"]
