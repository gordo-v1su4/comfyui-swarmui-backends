# ComfyUI SwarmUI Backend - Coolify Deployment Guide

This guide adapts the RunPod ComfyUI V45 installation for deployment on your home server using Coolify as a SwarmUI backend.

## Overview

This setup creates a ComfyUI backend service that SwarmUI can connect to, following the original RunPod installation instructions but optimized for Coolify deployment.

## Prerequisites

1. **Coolify installed** on your home server
2. **NVIDIA GPU** with CUDA support
3. **Docker with NVIDIA Container Runtime** configured
4. **Sufficient disk space** (at least 50GB for models and cache)
5. **SwarmUI instance** running separately (this is just the backend)

## Deployment Steps

### 1. Repository Setup

Clone or upload this repository to your Coolify instance:

```bash
git clone https://github.com/gordo-v1su4/comfyui-swarmui-backends.git
cd comfyui-swarmui-backends
```

### 2. Coolify Configuration

In Coolify, create a new service with these settings:

**Service Type:** Docker Compose
**Repository:** Point to this repository
**Docker Compose File:** `docker-compose.yml`

### 3. Environment Variables

Set these environment variables in Coolify:

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
- `comfyui_models` - Model storage
- `comfyui_output` - Generated outputs
- `comfyui_input` - Input files
- `comfyui_custom_nodes` - Custom node installations
- `huggingface_cache` - HuggingFace model cache

### 5. Network Configuration

**Port Mapping:**
- `8188` - ComfyUI API (for SwarmUI backend connection)

**Health Check:**
- URL: `http://localhost:8188/system_stats`
- Interval: 30s
- Timeout: 10s
- Start Period: 120s (allows time for model loading)

## SwarmUI Backend Configuration

### 1. Add Backend in SwarmUI

In your SwarmUI instance, add a new backend with these settings:

**Backend Type:** ComfyUI
**Backend URL:** `http://your-server-ip:8188` or `http://comfyui.your-domain.com`
**Name:** ComfyUI Home Server

### 2. Backend Configuration JSON

Use the provided `swarmui-backend-config.json` as reference:

```json
{
  "backend_name": "ComfyUI Home Server",
  "backend_type": "ComfyUI Remote",
  "configuration": {
    "url": "http://your-server-ip:8188",
    "timeout": 300,
    "max_concurrent_requests": 4
  },
  "performance_optimization": {
    "recommended_args": [
      "--use-sage-attention",
      "--gpu-only",
      "--disable-xformers",
      "--disable-opt-split-attention"
    ]
  }
}
```

## Model Management

### 1. Download Models

After deployment, you can download models using the included scripts:

```bash
# Access the running container
docker exec -it comfyui-swarmui-backend bash

# Activate the virtual environment
cd /workspace/ComfyUI
source venv/bin/activate

# Download IP Adapters and Face ID models
cd /workspace
python Download_IP_Adapters_Fast.py

# Download additional models
python Download_Models.py
```

### 2. Manual Model Upload

Upload models to the appropriate volume directories:
- **Checkpoints:** `comfyui_models/checkpoints/`
- **LoRAs:** `comfyui_models/loras/`
- **VAE:** `comfyui_models/vae/`
- **ControlNet:** `comfyui_models/controlnet/`

## Included Features (from RunPod V45)

### Custom Nodes Installed:
- **ComfyUI-Manager** - Node management
- **ComfyUI_IPAdapter_plus** - IP Adapter support
- **ComfyUI-ReActor** - Face swapping
- **ComfyUI-GGUF** - GGUF model support
- **ComfyUI-Impact-Pack** - Additional tools

### Optimizations:
- **SageAttention** - Memory efficient attention
- **Flash Attention 2** - Faster attention computation
- **Custom XFormers** - Optimized transformers
- **PyTorch 2.7.0** with CUDA 12.8 support

### Workflows Included:
- **Multi-Talk** - AI talking head generation
- **ReActor** - Face swapping workflows
- **3D Transfer** - Clothing and 3D figure workflows

## Troubleshooting

### 1. Container Won't Start
- Check GPU drivers and NVIDIA Container Runtime
- Verify sufficient disk space
- Check Coolify logs for build errors

### 2. SwarmUI Can't Connect
- Verify port 8188 is accessible
- Check firewall settings
- Ensure container is healthy: `docker ps`

### 3. Out of Memory Errors
Add memory optimization arguments in SwarmUI backend config:
```json
"memory_optimization": [
  "--lowvram",
  "--cpu-vae"
]
```

### 4. Slow Performance
Enable speed optimizations:
```json
"speed_optimization": [
  "--use-split-cross-attention",
  "--use-quad-cross-attention"
]
```

## Monitoring

### Health Checks
The service includes automatic health checks:
- **Endpoint:** `/system_stats`
- **Frequency:** Every 30 seconds
- **Timeout:** 10 seconds

### Logs
Monitor logs through Coolify dashboard or:
```bash
docker logs comfyui-swarmui-backend -f
```

### Resource Usage
Monitor GPU usage:
```bash
nvidia-smi
```

## Maintenance

### Updates
To update ComfyUI and custom nodes:
```bash
docker exec -it comfyui-swarmui-backend bash
cd /workspace/ComfyUI
git pull
cd custom_nodes/ComfyUI-Manager
git pull
# Repeat for other custom nodes
```

### Backup
Important directories to backup:
- Model volumes (especially custom models)
- Custom node configurations
- Workflow files

## Performance Tuning

### For High-End GPUs (24GB+ VRAM):
```json
"extra_args": [
  "--use-sage-attention",
  "--gpu-only",
  "--preview-method", "auto"
]
```

### For Mid-Range GPUs (8-16GB VRAM):
```json
"extra_args": [
  "--use-sage-attention",
  "--lowvram",
  "--preview-method", "auto"
]
```

### For Low-End GPUs (4-8GB VRAM):
```json
"extra_args": [
  "--lowvram",
  "--cpu-vae",
  "--preview-method", "auto"
]
```

## Security Considerations

1. **Network Access:** Limit access to port 8188 to your SwarmUI instance
2. **Authentication:** Consider adding reverse proxy authentication
3. **Updates:** Keep base images and dependencies updated
4. **Monitoring:** Monitor resource usage and access logs

## Support

For issues specific to:
- **ComfyUI:** Check ComfyUI GitHub repository
- **SwarmUI Integration:** Check SwarmUI documentation
- **Coolify Deployment:** Check Coolify documentation
- **This Setup:** Create an issue in this repository

## Original RunPod Instructions Reference

This deployment is based on the RunPod ComfyUI V45 package with these adaptations:
- Changed from RunPod template to Coolify deployment
- Modified networking for SwarmUI backend usage
- Added persistent volume management
- Included health checks and monitoring
- Optimized for home server deployment

The original RunPod instructions are preserved in `Runpod_Instructions_READ.txt` for reference.
