# Coolify Deployment Guide for ComfyUI + SwarmUI

This guide provides step-by-step instructions for deploying your ComfyUI + SwarmUI Docker setup using Coolify.

## Prerequisites

- Coolify instance running and accessible
- GitHub repository with the Dockerfile (already completed)
- Access to your home server's file system for volume mapping

## Step 1: Access Coolify

1. Open a web browser and navigate to your Coolify installation URL
2. Log in to your Coolify dashboard

## Step 2: Create a New Project

1. In the Coolify dashboard, click "New Project"
2. Give your project a name (e.g., "ComfyUI-SwarmUI")
3. Add a description (optional)
4. Click "Create Project"

## Step 3: Add a New Resource

1. Inside your newly created project, click "New Resource"
2. Select "Public Repository" from the Git-based options
3. Configure the resource with the following settings:

### Basic Configuration
- **Git Repository**: `https://github.com/gordo-v1su4/comfyui-swarmui-backends.git`
- **Branch**: `main`
- **Build Pack**: Select "Dockerfile"
- **Base Directory**: `/` (leave as default)
- **Rate Limit**: Leave empty (optional)

**Note**: After clicking "Continue", you'll be taken to the General configuration section where you can configure ports, storage, and other settings.

### Advanced Configuration

#### Environment Variables
Add the following environment variables:
```
CUDA_VISIBLE_DEVICES=0
HF_HOME=/workspace/huggingface
DEBIAN_FRONTEND=noninteractive
```

#### Volume Mappings
Configure the following volume mappings to persist your data:

| Container Path | Host Path | Description |
|----------------|-----------|-------------|
| `/workspace/ComfyUI/models` | `/home/user/comfyui_models` | ComfyUI model files |
| `/workspace/ComfyUI/output` | `/home/user/comfyui_output` | Generated images |
| `/workspace/SwarmUI/Models` | `/home/user/swarmui_models` | SwarmUI model files |
| `/workspace/logs` | `/home/user/comfyui_logs` | Application logs |
| `/workspace/configs` | `/home/user/comfyui_configs` | Configuration files |

#### Resource Limits (Optional)
- **Memory**: 8GB minimum (16GB+ recommended)
- **CPU**: 4 cores minimum
- **GPU**: Enable GPU access if available

## Step 4: Configure Application Settings

After clicking "Continue", you'll see the "General" configuration section. Configure the following:

### Network Configuration
- **Ports Exposes**: Change from `3000` to `8188` (ComfyUI default port)
- **Ports Mappings**: Change from `3000:3000` to `8188:8188`

### Build Configuration
- **Base Directory**: Keep as `/`
- **Dockerfile Location**: Keep as `/Dockerfile`
- **Custom Docker Options**: Add GPU support (optional):
  ```
  --runtime=nvidia --gpus all
  ```

## Step 5: Configure Persistent Storage

Navigate to "Persistent Storage" in the left sidebar and add these Volume Mounts:

| Name | Source Path | Destination Path | Description |
|------|-------------|------------------|-------------|
| `/workspace/ComfyUI/models` | `/root` (or your preferred path) | `/home/user/comfyui_models` | ComfyUI model files |
| `/workspace/ComfyUI/output` | `/root` (or your preferred path) | `/home/user/comfyui_output` | Generated images |
| `/workspace/SwarmUI/Models` | `/root` (or your preferred path) | `/home/user/swarmui_models` | SwarmUI model files |
| `/workspace/logs` | `/root` (or your preferred path) | `/home/user/comfyui_logs` | Application logs |
| `/workspace/configs` | `/root` (or your preferred path) | `/home/user/comfyui_configs` | Configuration files |

## Step 6: Configure Resource Limits

Navigate to "Resource Limits" in the left sidebar:

### CPU Configuration
- **Number of CPUs**: Set to `4` (minimum) or `8` (recommended)
- **CPU sets to use**: Keep at `8`
- **CPU Weight**: Keep at `1024`

### Memory Configuration
- **Soft Memory Limit**: Set to `8GB` (minimum)
- **Swappiness**: Keep at `60`
- **Maximum Memory Limit**: Set to `16GB` (recommended)
- **Maximum Swap Limit**: Keep at `0`

### GPU Configuration
- **Enable GPU**: Check this option if available

## Step 7: Configure Environment Variables

Navigate to "Environment Variables" in the left sidebar and add:

```
CUDA_VISIBLE_DEVICES=0
HF_HOME=/workspace/huggingface
DEBIAN_FRONTEND=noninteractive
NVIDIA_VISIBLE_DEVICES=all
```

## Step 8: Deploy the Application

1. Review all your configuration settings
2. Click the "▷ Deploy" button in the top navigation
3. Monitor the build process in the logs
4. Wait for the deployment to complete

## Step 9: Access Your Applications

Once deployed successfully, you can access:

- **ComfyUI**: `http://your-coolify-domain:8188`
- **SwarmUI**: `http://your-coolify-domain:7860`

**Note**: SwarmUI will be accessible through the same container on port 7860, but you may need to configure port forwarding or access it through the container's internal network.

## Step 10: Configure SwarmUI with ComfyUI Backend

1. Access SwarmUI through your browser
2. Navigate to "Server" → "Backends" tab
3. Click "Add Backend"
4. Configure the backend with these settings:

### Backend Configuration
- **Type**: `ComfyUI Self-Starting`
- **Name**: `ComfyUI Local`
- **StartScript**: `/workspace/ComfyUI/main.py`
- **ExtraArgs**: `--listen 0.0.0.0 --port 8188 --use-sage-attention --gpu-only`
- **Working Directory**: `/workspace/ComfyUI`

### Performance Optimization Arguments
You can add these arguments to the ExtraArgs field for better performance:
```
--use-sage-attention --gpu-only --disable-xformers --disable-opt-split-attention
```

## Step 11: Download and Install Models

### Option 1: Using the Unified Model Downloader (Recommended)

1. Download the unified model downloader application
2. Run it on your local machine
3. Download the models you need
4. Transfer the models to your server's mapped volume directories:
   - ComfyUI models: `/home/user/comfyui_models`
   - SwarmUI models: `/home/user/swarmui_models`

### Option 2: Manual Model Installation

1. Download models manually from Hugging Face or other sources
2. Place them in the appropriate directories on your server
3. Ensure proper file permissions

## Step 12: Verify Installation

1. **Test ComfyUI**:
   - Load a model in ComfyUI
   - Create a simple workflow
   - Generate an image to verify everything works

2. **Test SwarmUI**:
   - Connect to the ComfyUI backend
   - Test the connection
   - Try running a simple workflow

## Troubleshooting

### Common Issues

#### Build Failures
- Check the build logs in Coolify dashboard
- Ensure all dependencies are properly specified in the Dockerfile
- Verify the repository URL is correct
- Check that the Dockerfile is in the root directory

#### Port Configuration Issues
- Ensure "Ports Exposes" is set to `8188`
- Ensure "Ports Mappings" is set to `8188:8188`
- Check that the port isn't already in use by another application

#### GPU Issues
- Verify GPU is enabled in Resource Limits section
- Check that NVIDIA Container Toolkit is installed on the host
- Ensure CUDA drivers are up to date
- Verify Custom Docker Options include `--runtime=nvidia --gpus all`

#### Volume Mount Issues
- Ensure all volume mounts are properly configured in Persistent Storage
- Check that source paths exist on the host system
- Verify file permissions on host directories

#### Model Loading Issues
- Verify model files are in the correct directories
- Check file permissions
- Ensure models are compatible with your ComfyUI version

### Logs and Debugging

1. **View Application Logs**:
   - Access logs through Coolify dashboard
   - Check the `/home/user/comfyui_logs` directory

2. **Container Logs**:
   - Use `docker logs <container-name>` on the host
   - Check Coolify's built-in log viewer

## Performance Optimization

### GPU Optimization
- Enable GPU access in Coolify
- Use performance arguments in SwarmUI backend configuration
- Monitor GPU memory usage

### Memory Optimization
- Increase container memory limits if needed
- Use smaller batch sizes in workflows
- Close unused browser tabs

### Storage Optimization
- Regularly clean up generated images
- Use efficient model formats
- Consider using model merging for space savings

## Maintenance

### Regular Updates
1. Monitor for updates to ComfyUI and SwarmUI
2. Update your Dockerfile as needed
3. Redeploy through Coolify

### Backup Strategy
1. Regularly backup your model directories
2. Export important workflows from ComfyUI
3. Backup configuration files

### Monitoring
1. Monitor resource usage through Coolify
2. Check application logs regularly
3. Monitor disk space usage

## Security Considerations

1. **Network Security**:
   - Use HTTPS if exposing to the internet
   - Configure firewall rules appropriately
   - Consider using a reverse proxy

2. **Access Control**:
   - Implement authentication if needed
   - Restrict access to sensitive directories
   - Monitor access logs

3. **Data Protection**:
   - Encrypt sensitive data
   - Regular backups
   - Secure model storage

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review ComfyUI and SwarmUI documentation
3. Check Coolify documentation
4. Open an issue in the GitHub repository

## Additional Resources

- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [SwarmUI Documentation](https://github.com/mcmonkeyprojects/SwarmUI)
- [Coolify Documentation](https://coolify.io/docs)
- [Docker Documentation](https://docs.docker.com/)
