# ComfyUI SwarmUI Backend - Coolify Deployment Guide (RunPod V45 Compatible)

This guide provides exact replication of the RunPod ComfyUI V45 installation for deployment on your home server using Coolify.

## Overview

This setup creates a ComfyUI backend service that exactly matches the RunPod V45 installation, deployable through Coolify.

## Prerequisites

1. **Coolify installed** on your home server
2. **NVIDIA GPU** with CUDA support
3. **Docker with NVIDIA Container Runtime** configured
4. **Sufficient disk space** (at least 50GB for models and cache)
5. **Python 3.10** (required for the wheel files)

## Quick Setup

Run the setup script to verify your system:

```bash
chmod +x setup-coolify.sh
sudo ./setup-coolify.sh
```

## Deployment Steps

### 1. Repository Setup

Clone or upload this repository to your Coolify instance:

```bash
git clone https://github.com/your-repo/comfyui-swarmui-backends.git
cd comfyui-swarmui-backends
```

### 2. Coolify Configuration

In Coolify, create a new service with these settings:

**Service Type:** Docker Compose
**Repository:** Point to this repository
**Docker Compose File:** `docker-compose.yml`

### 3. Environment Variables

Set these environment variables in Coolify (exactly as RunPod):

```env
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility
CUDA_VISIBLE_DEVICES=0
PYTHONUNBUFFERED=1
HF_HOME=/workspace
HF_HUB_ENABLE_HF_TRANSFER=1
HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240
DOMAIN=your-domain.com  # Optional: for Traefik routing
```

### 4. Volume Configuration

The following volumes will be automatically created:
- `comfyui_models` - Model storage at `/workspace/ComfyUI/models`
- `comfyui_output` - Generated outputs at `/workspace/ComfyUI/output`
- `comfyui_input` - Input files at `/workspace/ComfyUI/input`
- `comfyui_custom_nodes` - Custom node installations at `/workspace/ComfyUI/custom_nodes`
- `huggingface_cache` - HuggingFace model cache at `/workspace`

### 5. Network Configuration

**Port Mapping:**
- `3000` - ComfyUI API (exactly as RunPod)

**Health Check:**
- URL: `http://localhost:3000/system_stats`
- Interval: 30s
- Timeout: 10s
- Start Period: 120s

## Post-Deployment Steps

### 1. Access the Container

After deployment, access the running container:

```bash
docker exec -it comfyui-swarmui-backend bash
```

### 2. Download Models (Following RunPod Instructions)

```bash
# Already in /workspace
export HF_HUB_ENABLE_HF_TRANSFER=1

# Download IP Adapters
python Download_IP_Adapters_Fast.py

# Download additional models
python Download_Models.py
```

### 3. Manual Model Upload

Upload models to the appropriate directories:
- **Checkpoints:** `/workspace/ComfyUI/models/checkpoints/`
- **LoRAs:** `/workspace/ComfyUI/models/loras/`
- **VAE:** `/workspace/ComfyUI/models/vae/`

## Running ComfyUI

The container automatically starts ComfyUI using the exact RunPod command:

```bash
apt update
apt install psmisc
fuser -k 3000/tcp
cd /workspace/ComfyUI/venv
source bin/activate
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 3000 --use-sage-attention
```

If you need to restart manually, exec into the container and run:

```bash
/workspace/start.sh
```

## Installed Components (Exact RunPod V45)

### Base Image:
- **runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04**

### PyTorch Stack:
- **PyTorch 2.7.0** with CUDA 12.8
- **TorchVision** and **TorchAudio**

### Optimizations:
- **Flash Attention 2.7.4.post1**
- **SageAttention 2.1.1**
- **XFormers 0.0.30**

### Custom Nodes:
- **ComfyUI-Manager**
- **ComfyUI_IPAdapter_plus**
- **ComfyUI-ReActor**
- **ComfyUI-GGUF**
- **ComfyUI-Impact-Pack**

### Additional Packages:
- InsightFace
- ONNX Runtime GPU
- Triton
- DeepSpeed
- HuggingFace Hub with transfer acceleration

## Troubleshooting

### Container Build Fails
```bash
# Check Docker logs
docker logs comfyui-swarmui-backend

# Verify NVIDIA runtime
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Port 3000 Already in Use
```bash
# Kill existing process
fuser -k 3000/tcp

# Or use a different port in docker-compose.yml
```

### GPU Not Detected
```bash
# Verify NVIDIA drivers
nvidia-smi

# Check Docker GPU access
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Python Version Mismatch
The wheel files require Python 3.10. The RunPod base image provides this exact version.

## SwarmUI Integration

### Connect SwarmUI to this Backend

1. In SwarmUI, add a new backend:
   - **Type:** ComfyUI
   - **URL:** `http://your-server-ip:3000`
   - **Name:** ComfyUI RunPod V45

2. Test the connection using SwarmUI's test button

### Performance Settings

For optimal performance with RunPod V45 optimizations:
```json
{
  "extra_args": [
    "--use-sage-attention",
    "--gpu-only"
  ]
}
```

## Maintenance

### Update ComfyUI
```bash
docker exec -it comfyui-swarmui-backend bash
cd /workspace/ComfyUI
git pull
cd custom_nodes/ComfyUI-Manager
git pull
```

### Monitor Resources
```bash
# GPU usage
nvidia-smi

# Container logs
docker logs -f comfyui-swarmui-backend

# System stats
curl http://localhost:3000/system_stats
```

## Notes

This deployment exactly replicates the RunPod ComfyUI V45 installation with:
- Same base image and Python version
- Identical package versions and installation order
- Same custom nodes and optimizations
- Matching startup commands and parameters

The only difference is the containerization for Coolify deployment instead of RunPod's platform.
