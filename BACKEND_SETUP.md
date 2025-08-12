# ComfyUI Backend Setup

This container runs **only ComfyUI** as a backend service for your local SwarmUI instance.

## What this container does:
- Runs ComfyUI on port 8188
- Configured to accept remote connections
- Uses GPU acceleration (when available)
- Optimized for backend usage

## Connecting from SwarmUI:

1. **Deploy this container** to Coolify or run locally
2. **Note the URL/IP** where ComfyUI is accessible (e.g., `http://your-server:8188`)
3. **In your local SwarmUI**, go to the backends configuration
4. **Add a new ComfyUI backend** with the URL: `http://your-server:8188`

## Testing the connection:
- Visit `http://your-server:8188` in a browser to see ComfyUI interface
- Your local SwarmUI should be able to connect and use this as a secondary GPU

## Ports:
- **8188** - ComfyUI API and web interface

## Notes:
- No SwarmUI runs in this container
- This is purely a ComfyUI backend service
- Perfect for distributed GPU setups
