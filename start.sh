#!/bin/bash

# Start ComfyUI in the background with arguments from the RunPod script
echo "Starting ComfyUI..."
python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188 --use-sage-attention --gpu-only &

# Start SwarmUI in the background
echo "Starting SwarmUI..."
/workspace/SwarmUI/launch-linux.sh &

# Wait for any process to exit so the container doesn't stop immediately
wait -n

# Exit with status of process that exited first
exit $?