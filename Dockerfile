# Use the same base image as the RunPod template for consistency
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set environment variables from the script
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV HF_HOME="/workspace/huggingface"
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Set work directory
WORKDIR /workspace

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    psmisc \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone ComfyUI and set it as the working directory
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI

# 3. Create and activate a Python virtual environment (good practice from the script)
RUN python3 -m venv venv
ENV PATH="/workspace/ComfyUI/venv/bin:$PATH"

# 4. Upgrade pip and install requirements WITHOUT the conflicting torch versions
RUN python -m pip install --no-cache-dir --upgrade pip
# We filter out torch, torchvision, and torchaudio to install them manually later
RUN awk '!/torch/' requirements.txt > temp_requirements.txt
RUN pip install --no-cache-dir -r temp_requirements.txt

# 5. Install the EXACT custom-compiled libraries from the video
# Note: Using the cu121 index to match the base Docker image's CUDA version for max compatibility
RUN pip install --no-cache-dir torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
RUN pip install --no-cache-dir https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl

# 6. Install other key Python packages from the script
RUN pip install --no-cache-dir insightface onnxruntime-gpu triton deepspeed accelerate diffusers

# 7. Clone all Custom Nodes
WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
RUN git clone https://github.com/Gourieff/ComfyUI-ReActor.git
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
RUN git clone https://github.com/city96/ComfyUI-GGUF.git && pip install -r ComfyUI-GGUF/requirements.txt

# 8. Run the install scripts for specific custom nodes
RUN cd ComfyUI-ReActor && python install.py
RUN cd ComfyUI-Impact-Pack && python install.py

# 9. Clone and set up SwarmUI
WORKDIR /workspace
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git
RUN cd SwarmUI && chmod +x install.sh && ./install.sh --no-backend

# 10. Copy the startup script into the container
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Expose ports for both services
EXPOSE 8188 7860

# Set the command to our startup script
CMD ["/workspace/start.sh"]