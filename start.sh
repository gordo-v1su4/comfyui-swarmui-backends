#!/bin/bash

# Set HF_HOME environment variable
export HF_HOME="/workspace"

# Kill any existing processes on port 8188 (following RunPod pattern)
fuser -k 8188/tcp 2>/dev/null || true

# Navigate to ComfyUI venv and activate (exactly as per RunPod instructions)
cd /workspace/ComfyUI/venv
source bin/activate
cd /workspace/ComfyUI

# Start ComfyUI as a backend for remote SwarmUI instance
echo "Starting ComfyUI backend..."
echo "ComfyUI will be accessible on port 8188"
echo "Configure your local SwarmUI to connect to this backend"

# Run ComfyUI exactly as per RunPod instructions (but on port 8188)
python main.py --listen 0.0.0.0 --port 8188 --use-sage-attention
