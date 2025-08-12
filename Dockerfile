# Use the same base image as the RunPod template for consistency
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /workspace

# 1. Copy your custom zip file into the Docker image
# Zip detected in repo root: Comfy_UI_V45.zip
COPY Comfy_UI_V45.zip /workspace/

# 2. Install 'unzip' and then extract your file
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*
RUN unzip /workspace/Comfy_UI_V45.zip

# 3. Make the installation script from the zip file executable
# Replace 'RunPod_Install.sh' if your script has a different name
RUN chmod +x /workspace/RunPod_Install.sh

# 4. Execute the installation script
# This script should handle all the complex setup for you
RUN /workspace/RunPod_Install.sh

# 5. Copy the startup script into the container
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Expose the ports for ComfyUI and SwarmUI
EXPOSE 8188 7860

# Set the command to our startup script
CMD ["/workspace/start.sh"]