#!/bin/bash

# Start ComfyUI in the background
echo "Starting ComfyUI..."
python /app/ComfyUI/main.py --listen 0.0.0.0 &

# Start SwarmUI in the background
echo "Starting SwarmUI..."
/app/SwarmUI/launch-linux.sh &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?