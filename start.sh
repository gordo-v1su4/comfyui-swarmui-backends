#!/bin/bash

# Update apt and install psmisc (as per RunPod instructions)
apt update
apt install -y psmisc

# Kill any existing processes on port 3000 (following RunPod pattern)
fuser -k 3000/tcp 2>/dev/null || true

# Navigate to venv directory and activate (exactly as RunPod)
cd /workspace/ComfyUI/venv
source bin/activate

# Navigate to ComfyUI directory
cd /workspace/ComfyUI

# Start ComfyUI with exact RunPod parameters
python main.py --listen 0.0.0.0 --port 3000 --use-sage-attention
