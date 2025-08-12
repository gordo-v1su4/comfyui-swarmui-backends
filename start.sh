#!/bin/bash

# ComfyUI + SwarmUI Startup Script
# This script starts both ComfyUI and SwarmUI services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for a service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        
        print_status "Attempt $attempt/$max_attempts - $service_name not ready yet..."
        sleep 2
        ((attempt++))
    done
    
    print_error "$service_name failed to start within the expected time"
    return 1
}

# Function to start ComfyUI
start_comfyui() {
    print_status "Starting ComfyUI..."
    
    if [ ! -d "/workspace/ComfyUI" ]; then
        print_error "ComfyUI directory not found!"
        return 1
    fi
    
    cd /workspace/ComfyUI
    
    # Check if port 8188 is available
    if check_port 8188; then
        print_warning "Port 8188 is already in use. ComfyUI may not start properly."
    fi
    
    # Start ComfyUI in the background
    python main.py --listen 0.0.0.0 --port 8188 > /workspace/logs/comfyui.log 2>&1 &
    COMFYUI_PID=$!
    
    # Wait for ComfyUI to be ready
    if wait_for_service "http://localhost:8188" "ComfyUI"; then
        print_success "ComfyUI started successfully (PID: $COMFYUI_PID)"
        return 0
    else
        print_error "Failed to start ComfyUI"
        return 1
    fi
}

# Function to start SwarmUI
start_swarmui() {
    print_status "Starting SwarmUI..."
    
    if [ ! -d "/workspace/SwarmUI" ]; then
        print_error "SwarmUI directory not found!"
        return 1
    fi
    
    cd /workspace/SwarmUI
    
    # Check if port 7860 is available
    if check_port 7860; then
        print_warning "Port 7860 is already in use. SwarmUI may not start properly."
    fi
    
    # Start SwarmUI in the background
    python main.py --listen 0.0.0.0 --port 7860 > /workspace/logs/swarmui.log 2>&1 &
    SWARMUI_PID=$!
    
    # Wait for SwarmUI to be ready
    if wait_for_service "http://localhost:7860" "SwarmUI"; then
        print_success "SwarmUI started successfully (PID: $SWARMUI_PID)"
        return 0
    else
        print_error "Failed to start SwarmUI"
        return 1
    fi
}

# Function to handle shutdown
cleanup() {
    print_status "Shutting down services..."
    
    if [ ! -z "$COMFYUI_PID" ]; then
        print_status "Stopping ComfyUI (PID: $COMFYUI_PID)..."
        kill $COMFYUI_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$SWARMUI_PID" ]; then
        print_status "Stopping SwarmUI (PID: $SWARMUI_PID)..."
        kill $SWARMUI_PID 2>/dev/null || true
    fi
    
    print_success "Services stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Create log directory if it doesn't exist
mkdir -p /workspace/logs

# Print startup information
print_status "ComfyUI + SwarmUI Backend Starting..."
print_status "ComfyUI will be available at: http://localhost:8188"
print_status "SwarmUI will be available at: http://localhost:7860"

# Check CUDA availability
if command -v nvidia-smi &> /dev/null; then
    print_success "NVIDIA GPU detected"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
else
    print_warning "No NVIDIA GPU detected. Running in CPU mode."
fi

# Start services
start_comfyui
start_swarmui

# Keep the script running and monitor services
print_success "All services started successfully!"
print_status "Monitoring services... (Press Ctrl+C to stop)"

# Monitor services
while true; do
    # Check if ComfyUI is still running
    if ! kill -0 $COMFYUI_PID 2>/dev/null; then
        print_error "ComfyUI process died unexpectedly"
        break
    fi
    
    # Check if SwarmUI is still running
    if ! kill -0 $SWARMUI_PID 2>/dev/null; then
        print_error "SwarmUI process died unexpectedly"
        break
    fi
    
    sleep 10
done

# If we get here, one of the services died
cleanup
