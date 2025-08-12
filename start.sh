#!/bin/bash

# Activate the Python virtual environment
source /workspace/ComfyUI/venv/bin/activate

# Start ComfyUI in the background using arguments from the instructions
echo "Starting ComfyUI..."
python /workspace/ComfyUI/main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    --use-sage-attention \
    --gpu-only &

# Start SwarmUI in the background
echo "Starting SwarmUI..."
/workspace/SwarmUI/launch-linux.sh &

# Wait for any process to exit so the container keeps running
wait -n

# Exit with status of process that exited first
exit $?