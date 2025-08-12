# ComfyUI + SwarmUI Docker Backend

This repository contains a Docker setup for running ComfyUI and SwarmUI together in a containerized environment, optimized for RunPod and similar cloud GPU platforms.

## Features

- **ComfyUI**: Advanced node-based UI for Stable Diffusion workflows
- **SwarmUI**: Web-based interface for managing and orchestrating AI model workflows
- **ComfyUI Manager**: Plugin management system for ComfyUI
- **CUDA 12.1.1 Support**: Optimized for modern NVIDIA GPUs
- **PyTorch 2.2.0**: Latest stable PyTorch version with CUDA support

## Prerequisites

- Docker and Docker Compose installed
- NVIDIA GPU with CUDA support (for GPU acceleration)
- NVIDIA Container Toolkit (for GPU access in containers)
- At least 8GB RAM (16GB+ recommended)
- At least 50GB free disk space

## Quick Start

### Using Docker Compose (Recommended)

1. Clone this repository:
```bash
git clone <your-repo-url>
cd comfyui-swarmui-backends
```

2. Create necessary directories:
```bash
mkdir -p models outputs configs logs
```

3. Build and start the services:
```bash
docker-compose up -d --build
```

4. Access the applications:
- ComfyUI: http://localhost:8188
- SwarmUI: http://localhost:7860

### Using Docker directly

1. Build the image:
```bash
docker build -t comfyui-swarmui .
```

2. Run the container:
```bash
docker run -d \
  --name comfyui-swarmui \
  --gpus all \
  -p 8188:8188 \
  -p 7860:7860 \
  -v $(pwd)/models:/workspace/models \
  -v $(pwd)/outputs:/workspace/outputs \
  -v $(pwd)/configs:/workspace/configs \
  -v $(pwd)/logs:/workspace/logs \
  comfyui-swarmui
```

## Directory Structure

```
comfyui-swarmui-backends/
├── Dockerfile              # Main Docker configuration
├── docker-compose.yml      # Docker Compose configuration
├── .dockerignore          # Files to exclude from Docker build
├── README.md              # This file
├── models/                # AI models (mounted volume)
├── outputs/               # Generated outputs (mounted volume)
├── configs/               # Configuration files (mounted volume)
└── logs/                  # Application logs (mounted volume)
```

## Ports

- **8188**: ComfyUI web interface
- **7860**: SwarmUI web interface

## Environment Variables

- `CUDA_VISIBLE_DEVICES`: GPU device selection (default: 0)
- `HF_HOME`: Hugging Face cache directory (default: /workspace/huggingface)
- `DEBIAN_FRONTEND`: Non-interactive package installation

## Volumes

The following directories are mounted as volumes for persistence:

- `./models`: AI models and checkpoints
- `./outputs`: Generated images and outputs
- `./configs`: Configuration files
- `./logs`: Application logs

## Customization

### Adding Custom Models

Place your model files in the `models/` directory. The container will automatically detect them.

### Modifying ComfyUI Configuration

Edit the ComfyUI configuration by modifying files in the `configs/` directory.

### Installing Additional ComfyUI Nodes

You can add custom nodes by modifying the Dockerfile or by mounting them as volumes.

## Troubleshooting

### GPU Issues

If you encounter GPU-related issues:

1. Ensure NVIDIA Container Toolkit is installed:
```bash
# Ubuntu/Debian
sudo apt-get install nvidia-container-toolkit
sudo systemctl restart docker
```

2. Verify GPU access:
```bash
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```

### Port Conflicts

If ports 8188 or 7860 are already in use, modify the port mappings in `docker-compose.yml`:

```yaml
ports:
  - "8189:8188"  # Map host port 8189 to container port 8188
  - "7861:7860"  # Map host port 7861 to container port 7860
```

### Memory Issues

If you encounter memory issues:

1. Increase Docker memory limits
2. Reduce batch sizes in your workflows
3. Use smaller models

## Development

### Building for Development

```bash
docker build -t comfyui-swarmui:dev --target development .
```

### Running in Development Mode

```bash
docker-compose -f docker-compose.dev.yml up
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review ComfyUI and SwarmUI documentation
3. Open an issue in this repository

## Acknowledgments

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) - Node-based UI for Stable Diffusion
- [SwarmUI](https://github.com/mcmonkeyprojects/SwarmUI) - Web-based AI workflow management
- [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager) - Plugin management system
- [RunPod](https://runpod.io/) - Cloud GPU platform
