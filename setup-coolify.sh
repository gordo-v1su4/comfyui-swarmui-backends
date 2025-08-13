#!/bin/bash

# ComfyUI SwarmUI Backend - Coolify Setup Script
# This script helps prepare the deployment for Coolify

set -e

echo "🚀 ComfyUI SwarmUI Backend - Coolify Setup"
echo "=========================================="

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "⚠️  This script is designed for Linux. For Windows, use the manual setup instructions."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if NVIDIA Docker runtime is available
if ! docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
    echo "⚠️  NVIDIA Docker runtime not detected. GPU support may not work."
    echo "   Please install nvidia-container-toolkit if you have an NVIDIA GPU."
fi

# Check if Comfy_UI_V45.zip exists
if [ ! -f "Comfy_UI_V45.zip" ]; then
    echo "❌ Comfy_UI_V45.zip not found in current directory."
    echo "   Please ensure the zip file is present before running this script."
    exit 1
fi

echo "✅ Prerequisites check completed"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p configs logs

# Set proper permissions
echo "🔐 Setting permissions..."
chmod +x start.sh
chmod +x RunPod_Install.sh 2>/dev/null || true

# Validate docker-compose.yml
echo "🔍 Validating Docker Compose configuration..."
if command -v docker-compose &> /dev/null; then
    docker-compose config > /dev/null
    echo "✅ Docker Compose configuration is valid"
else
    echo "⚠️  docker-compose not found, skipping validation"
fi

# Display next steps
echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps for Coolify deployment:"
echo "1. Push this repository to your Git provider (GitHub, GitLab, etc.)"
echo "2. In Coolify, create a new service:"
echo "   - Type: Docker Compose"
echo "   - Repository: Your repository URL"
echo "   - Docker Compose file: docker-compose.yml"
echo "3. Set environment variables in Coolify:"
echo "   - NVIDIA_VISIBLE_DEVICES=all"
echo "   - CUDA_VISIBLE_DEVICES=0"
echo "   - HF_HOME=/workspace"
echo "   - HF_HUB_ENABLE_HF_TRANSFER=1"
echo "4. Deploy the service"
echo "5. Wait for the container to be healthy (may take 10-15 minutes)"
echo "6. Configure SwarmUI to connect to http://your-server-ip:8188"
echo ""
echo "📖 For detailed instructions, see COOLIFY_DEPLOYMENT.md"
echo "🔧 For troubleshooting, see DOCKER_TROUBLESHOOTING.md"
echo ""
echo "🏠 Your ComfyUI backend will be available at: http://your-server-ip:8188"
echo "📊 Health check endpoint: http://your-server-ip:8188/system_stats"
