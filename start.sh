#!/bin/bash

# Activate the Python virtual environment
source /workspace/ComfyUI/venv/bin/activate

# Start ComfyUI as a backend for remote SwarmUI instance
echo "Starting ComfyUI backend..."
echo "ComfyUI will be accessible on port 8188"
echo "Configure your local SwarmUI to connect to this backend"

# Run ComfyUI in foreground so container stays alive
python /workspace/ComfyUI/main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    --use-sage-attention \
    --gpu-only
