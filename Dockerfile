# Use a standard NVIDIA CUDA base image for better compatibility
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/data/huggingface
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Set work directory
WORKDIR /workspace

# Install system dependencies from the RunPod script
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3.10 \
    python3-pip \
    build-essential \
    psmisc \
    && rm -rf /var/lib/apt/lists/*

# Make python3.10 the default and upgrade pip
RUN ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
    python3 -m pip install --no-cache-dir --upgrade pip

# --- ComfyUI Setup ---
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI

# Install ComfyUI dependencies, but EXCLUDE torch to install it manually
RUN awk '!/torch/' requirements.txt > requirements_no_torch.txt
RUN pip install --no-cache-dir -r requirements_no_torch.txt

# Install the SPECIFIC torch version and custom wheels from the script
# Using cu121 to match the base image's CUDA version
RUN pip install --no-cache-dir torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl

# Install other high-level dependencies
RUN pip install --no-cache-dir insightface onnxruntime-gpu accelerate diffusers triton deepspeed

# --- Install Custom Nodes from the script ---
WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
RUN git clone https://github.com/Gourieff/ComfyUI-ReActor.git
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
RUN git clone https://github.com/city96/ComfyUI-GGUF.git && pip install -r ComfyUI-GGUF/requirements.txt

# Run install scripts for custom nodes that require it
RUN cd ComfyUI-ReActor && python install.py
RUN cd ComfyUI-Impact-Pack && python install.py

# --- SwarmUI Setup ---
WORKDIR /workspace
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git
RUN cd SwarmUI && chmod +x install.sh && ./install.sh --no-backend

# --- Final Setup ---
WORKDIR /workspace
# Copy a startup script that will launch both services
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Expose ports
EXPOSE 8188 7860

# Command to run the startup script
CMD ["/workspace/start.sh"]