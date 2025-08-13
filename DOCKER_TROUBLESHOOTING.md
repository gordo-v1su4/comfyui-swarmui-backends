# Docker Build Corruption Issue - Troubleshooting Guide

## Problem
You're experiencing this error when building Docker images:
```
ERROR: failed to solve: failed to register layer: exit status 1: unpigz: skipping: <stdin>: corrupted -- invalid deflate data (invalid literal/lengths set)
```

## Root Causes
1. Docker Desktop not running
2. Corrupted Docker image cache
3. Network issues during image download
4. Insufficient disk space
5. Docker daemon issues

## Solutions (Try in order)

### 1. Start Docker Desktop
- Open Docker Desktop from Windows Start menu
- Wait for it to fully start (green icon in system tray)
- Try building again

### 2. Clear Docker Cache
Once Docker Desktop is running, execute these commands:
```bash
# Remove all unused containers, networks, images, and build cache
docker system prune -a -f

# Remove all images (more aggressive)
docker image prune -a -f

# Remove build cache specifically
docker builder prune -a -f
```

### 3. Try Alternative Base Images
Use the alternative Dockerfile I created:
```bash
# Build with the alternative Dockerfile
docker build -f Dockerfile.alternative -t comfyui-backend .
```

### 4. Pull Base Image Manually
Try pulling the base image separately to isolate the issue:
```bash
# For original Dockerfile
docker pull pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

# For alternative approach
docker pull ubuntu:22.04
```

### 5. Use Different Docker Registry
If the issue persists, try using a different registry mirror:
```bash
# Add to Docker Desktop settings or daemon.json
{
  "registry-mirrors": [
    "https://mirror.gcr.io"
  ]
}
```

### 6. Check Disk Space
Ensure you have sufficient disk space:
```bash
# Check available space
df -h

# On Windows
dir C:\ /-c
```

### 7. Restart Docker Service
If still having issues:
```bash
# On Windows (run as administrator)
net stop com.docker.service
net start com.docker.service

# Or restart Docker Desktop completely
```

## Recommended Build Commands

### Option 1: Use Modified Original Dockerfile
```bash
docker build -t comfyui-backend .
```

### Option 2: Use Alternative Dockerfile (Recommended)
```bash
docker build -f Dockerfile.alternative -t comfyui-backend .
```

### Option 3: Build with No Cache
```bash
docker build --no-cache -t comfyui-backend .
```

## Testing the Build
After successful build, test the container:
```bash
# Run the container
docker run -d -p 8188:8188 --name comfyui-test comfyui-backend

# Check logs
docker logs comfyui-test

# Test the endpoint
curl http://localhost:8188

# Clean up
docker stop comfyui-test
docker rm comfyui-test
```

## Prevention
1. Keep Docker Desktop updated
2. Regularly clean Docker cache
3. Monitor disk space
4. Use stable base images
5. Consider using multi-stage builds for complex setups
