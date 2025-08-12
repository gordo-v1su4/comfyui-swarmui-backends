#!/bin/bash

# Model Setup Script for ComfyUI + SwarmUI
# This script helps set up the model directories and provides guidance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create directory structure
create_directories() {
    print_status "Creating model directories..."
    
    # Create base directories
    mkdir -p models/comfyui
    mkdir -p models/swarmui
    mkdir -p outputs
    mkdir -p configs
    mkdir -p logs
    
    # Create ComfyUI specific directories
    mkdir -p models/comfyui/checkpoints
    mkdir -p models/comfyui/vae
    mkdir -p models/comfyui/loras
    mkdir -p models/comfyui/embeddings
    mkdir -p models/comfyui/controlnet
    mkdir -p models/comfyui/upscale_models
    
    print_success "Directory structure created successfully!"
}

# Function to display model download instructions
show_download_instructions() {
    echo ""
    print_status "Model Download Instructions:"
    echo ""
    echo "1. Download the unified model downloader application"
    echo "2. Run it on your local machine"
    echo "3. Download the following model types:"
    echo ""
    echo "   Checkpoint Models (place in models/comfyui/checkpoints/):"
    echo "   - Stable Diffusion models (.safetensors, .ckpt)"
    echo "   - Examples: SD 1.5, SDXL, SDXL Turbo"
    echo ""
    echo "   VAE Models (place in models/comfyui/vae/):"
    echo "   - VAE files for better color reproduction"
    echo ""
    echo "   LoRA Models (place in models/comfyui/loras/):"
    echo "   - LoRA files for style and character training"
    echo ""
    echo "   Embeddings (place in models/comfyui/embeddings/):"
    echo "   - Textual inversion embeddings"
    echo ""
    echo "   ControlNet Models (place in models/comfyui/controlnet/):"
    echo "   - ControlNet models for pose, depth, etc."
    echo ""
    echo "   Upscale Models (place in models/comfyui/upscale_models/):"
    echo "   - ESRGAN, Real-ESRGAN models for upscaling"
    echo ""
    echo "4. Transfer the models to your server's mapped volume directories"
    echo ""
}

# Function to check if directories exist
check_directories() {
    print_status "Checking directory structure..."
    
    local missing_dirs=()
    
    # Check base directories
    for dir in models outputs configs logs; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    # Check ComfyUI model directories
    for subdir in checkpoints vae loras embeddings controlnet upscale_models; do
        if [ ! -d "models/comfyui/$subdir" ]; then
            missing_dirs+=("models/comfyui/$subdir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        print_success "All directories exist!"
    else
        print_warning "Missing directories:"
        for dir in "${missing_dirs[@]}"; do
            echo "  - $dir"
        done
        echo ""
        read -p "Would you like to create the missing directories? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_directories
        fi
    fi
}

# Function to show volume mapping information
show_volume_info() {
    echo ""
    print_status "Volume Mapping Information for Coolify:"
    echo ""
    echo "When configuring volumes in Coolify, use these mappings:"
    echo ""
    echo "Container Path                    | Host Path"
    echo "----------------------------------|----------------------------------"
    echo "/workspace/ComfyUI/models         | /home/user/comfyui_models"
    echo "/workspace/ComfyUI/output         | /home/user/comfyui_output"
    echo "/workspace/SwarmUI/Models         | /home/user/swarmui_models"
    echo "/workspace/logs                   | /home/user/comfyui_logs"
    echo "/workspace/configs                | /home/user/comfyui_configs"
    echo ""
    echo "Make sure these host directories exist and have proper permissions."
    echo ""
}

# Function to show quick start commands
show_quick_start() {
    echo ""
    print_status "Quick Start Commands:"
    echo ""
    echo "1. Build and run with Docker Compose:"
    echo "   docker-compose up -d --build"
    echo ""
    echo "2. Access the applications:"
    echo "   ComfyUI: http://localhost:8188"
    echo "   SwarmUI: http://localhost:7860"
    echo ""
    echo "3. Check logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "4. Stop the services:"
    echo "   docker-compose down"
    echo ""
}

# Main script logic
main() {
    echo "ComfyUI + SwarmUI Model Setup Script"
    echo "===================================="
    echo ""
    
    case "${1:-}" in
        "create")
            create_directories
            ;;
        "check")
            check_directories
            ;;
        "volumes")
            show_volume_info
            ;;
        "quickstart")
            show_quick_start
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  create     - Create the directory structure"
            echo "  check      - Check if directories exist"
            echo "  volumes    - Show volume mapping information"
            echo "  quickstart - Show quick start commands"
            echo "  help       - Show this help message"
            echo ""
            ;;
        *)
            echo "Welcome to the ComfyUI + SwarmUI Model Setup Script!"
            echo ""
            echo "This script helps you set up the model directories and provides"
            echo "guidance for deploying with Coolify."
            echo ""
            echo "Available commands:"
            echo "  $0 create     - Create the directory structure"
            echo "  $0 check      - Check if directories exist"
            echo "  $0 volumes    - Show volume mapping information"
            echo "  $0 quickstart - Show quick start commands"
            echo "  $0 help       - Show detailed help"
            echo ""
            echo "Running directory check..."
            check_directories
            show_download_instructions
            show_volume_info
            show_quick_start
            ;;
    esac
}

# Run the main function
main "$@"
