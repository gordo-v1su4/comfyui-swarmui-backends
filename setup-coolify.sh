#!/bin/bash

echo "ComfyUI SwarmUI Backend - Coolify Setup Script"
echo "=============================================="
echo ""
echo "This script prepares your Coolify deployment to match RunPod ComfyUI V45"
echo ""

# Check if running with proper permissions
if [ "$EUID" -ne 0 ]; then 
   echo "Please run as root or with sudo"
   exit 1
fi

# Check for NVIDIA drivers
echo "Checking NVIDIA drivers..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "ERROR: NVIDIA drivers not found. Please install NVIDIA drivers first."
    exit 1
fi

# Check for Docker
echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found. Please install Docker first."
    exit 1
fi

# Check for NVIDIA Container Toolkit
echo "Checking NVIDIA Container Toolkit..."
if ! docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "ERROR: NVIDIA Container Toolkit not working. Installing..."
    
    # Install NVIDIA Container Toolkit
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
    
    apt-get update
    apt-get install -y nvidia-container-toolkit
    systemctl restart docker
    
    # Test again
    if ! docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        echo "ERROR: NVIDIA Container Toolkit installation failed."
        exit 1
    fi
fi

echo "✓ NVIDIA drivers and container toolkit are working"
echo ""

# Create necessary directories
echo "Creating directories for volumes..."
mkdir -p ./configs
mkdir -p ./logs
chmod 755 ./configs ./logs

# Create a basic config file
echo "Creating default configuration..."
cat > ./configs/backend-config.json << 'EOF'
{
  "backend_name": "ComfyUI RunPod V45",
  "backend_type": "ComfyUI",
  "port": 3000,
  "performance_settings": {
    "use_sage_attention": true,
    "gpu_only": true
  }
}
EOF

# Create environment file for Coolify
echo "Creating Coolify environment file..."
cat > .env << 'EOF'
# NVIDIA Configuration
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility
CUDA_VISIBLE_DEVICES=0

# Python Environment
PYTHONUNBUFFERED=1

# HuggingFace Configuration
HF_HOME=/workspace
HF_HUB_ENABLE_HF_TRANSFER=1
HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240

# Domain for Traefik routing (update this)
DOMAIN=localhost

# ComfyUI Port
COMFYUI_PORT=3000
EOF

echo ""
echo "Setup complete! Next steps:"
echo ""
echo "1. Update the DOMAIN variable in .env file if using Traefik"
echo "2. In Coolify, create a new service:"
echo "   - Type: Docker Compose"
echo "   - Source: GitHub repository or direct upload"
echo "   - Compose file: docker-compose.yml"
echo ""
echo "3. Add these environment variables in Coolify:"
cat .env | grep -v "^#" | grep -v "^$" | while read line; do
    echo "   - $line"
done
echo ""
echo "4. Deploy the service"
echo "5. After deployment, access the container to download models:"
echo "   docker exec -it comfyui-swarmui-backend bash"
echo "   cd /workspace"
echo "   python Download_IP_Adapters_Fast.py"
echo "   python Download_Models.py"
echo ""
echo "6. Connect SwarmUI to: http://your-server:3000"
echo ""
echo "For issues, check: docker logs comfyui-swarmui-backend"
