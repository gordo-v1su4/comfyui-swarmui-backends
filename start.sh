#!/bin/bash

# Set environment variables
export HF_HOME="/workspace"
export HF_HUB_ENABLE_HF_TRANSFER=1

# Kill any existing processes on port 8188 (following RunPod pattern)
fuser -k 8188/tcp 2>/dev/null || true

# Start ComfyUI as a backend for remote SwarmUI instance
echo "Starting ComfyUI backend..."
echo "ComfyUI will be accessible on port 8188"
echo "Configure your local SwarmUI to connect to this backend"

# Navigate to ComfyUI directory and activate venv, then run
cd /workspace/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188 --use-sage-attention
