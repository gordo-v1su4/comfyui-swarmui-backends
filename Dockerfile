# Use RunPod PyTorch base image as specified in instructions
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set environment variables for HuggingFace and optimization
ENV HF_HOME="/workspace"
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    psmisc \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

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

# Create and activate virtual environment, install dependencies
RUN cd /workspace/ComfyUI && \
    python -m venv venv && \
    . venv/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install -r requirements.txt

# Install specific PyTorch version and optimized packages
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip uninstall torch torchvision xformers torchaudio --yes && \
    pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl && \
    pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl

# Install additional required packages
RUN cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    pip install insightface onnxruntime-gpu requests piexif triton deepspeed huggingface_hub hf_transfer accelerate diffusers

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
    pip install -r requirements.txt

# Setup ComfyUI-Manager
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    git reset --hard && \
    git stash && \
    git pull --force

# Setup ComfyUI-ReActor
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-ReActor && \
    cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd custom_nodes/ComfyUI-ReActor && \
    python install.py

# Setup ComfyUI-Impact-Pack
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    cd /workspace/ComfyUI && \
    . venv/bin/activate && \
    cd custom_nodes/ComfyUI-Impact-Pack && \
    python install.py

# Copy model download scripts and make them executable
RUN if [ -f "/workspace/Download_Reactor_Models.py" ]; then \
        cd /workspace/ComfyUI && \
        . venv/bin/activate && \
        cd /workspace && \
        python Download_Reactor_Models.py; \
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
python main.py --listen 0.0.0.0 --port 8188 --use-sage-attention --gpu-only --disable-xformers --disable-opt-split-attention\n\
' > /workspace/start_comfyui.sh && chmod +x /workspace/start_comfyui.sh

# Expose the port for ComfyUI backend (SwarmUI compatible)
EXPOSE 8188

# Add healthcheck for SwarmUI integration
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:8188/system_stats || exit 1

# Set the command to start ComfyUI for SwarmUI backend
CMD ["/workspace/start_comfyui.sh"]
