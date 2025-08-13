# Coolify Deployment: ComfyUI-only (Remote Backend for SwarmUI)

This guide explains how to deploy only ComfyUI on a Coolify server, using the exact RunPod-style install contained in `Comfy_UI_V45.zip`. Your SwarmUI stays on your local machine and connects to the remote ComfyUI over HTTP.

- Local machine: SwarmUI UI
- Coolify server: ComfyUI listening on 0.0.0.0:8188

The Dockerfile in this repo unpacks `Comfy_UI_V45.zip`, runs the RunPod install script if present, and starts ComfyUI. No SwarmUI runs in the container.

## Prerequisites

- A working Coolify instance (with GPU host if you need GPU acceleration)
- NVIDIA drivers + NVIDIA Container Toolkit on the Coolify host (for GPU)
- This repository accessible by Coolify (public or connected Git provider)

## 1) Create the Coolify service

- Type: Git Repository → Build Pack: Dockerfile
- Repository: https://github.com/gordo-v1su4/comfyui-swarmui-backends.git
- Branch: main
- Dockerfile path: /Dockerfile
- Exposed Port: 8188

## 2) Environment variables

Add (or confirm) the following:

- HF_HOME=/workspace
- HF_HUB_ENABLE_HF_TRANSFER=1
- Optional GPU hints (depending on your Coolify version/setup):
  - CUDA_VISIBLE_DEVICES=0
  - NVIDIA_VISIBLE_DEVICES=all

Note: The Dockerfile sets `HF_HOME=/workspace` by default. If you prefer to persist HF cache separately, you can set `HF_HOME=/workspace/huggingface` and mount a volume there (see below).

## 3) Persistent storage (recommended)

Add volume mounts so models and outputs persist across updates:

- /workspace/ComfyUI/models → <host models path>
- /workspace/ComfyUI/custom_nodes → <host custom nodes path>
- /workspace/ComfyUI/input → <host input path>
- /workspace/ComfyUI/output → <host output path>
- Optional HF cache (for faster downloads between deployments):
  - If HF_HOME=/workspace: mount /workspace
  - If HF_HOME=/workspace/huggingface: mount /workspace/huggingface

## 4) GPU settings (if applicable)

- Ensure the Coolify host has GPU drivers and NVIDIA Container Toolkit installed
- In the service Resource Limits, enable GPU
- If your Coolify requires it, set custom Docker options: `--gpus all`

## 5) Deploy

- Click Deploy
- After it starts, ComfyUI should be available at: http://your-domain:8188

Tip: This image includes a HEALTHCHECK. In Coolify you can see health status after the service starts responding.

## 6) Configure SwarmUI (on your local machine)

In your local SwarmUI, add the backend:

- Type: ComfyUI Remote (not Self-Starting)
- URL: http://your-domain-or-ip:8188
- Save, then Test the connection and try a simple workflow

## 7) Security considerations

- ComfyUI has no built-in authentication. If exposed to the internet:
  - Put it behind a reverse proxy with auth and HTTPS (Coolify’s built-in proxy or your own)
  - Restrict inbound ports with your firewall/VPN
- Only expose 8188 if you need public access. Otherwise keep it internal.

## 8) Troubleshooting

- Build fails:
  - Check build logs in Coolify
  - Verify Dockerfile path is /Dockerfile and the repo/branch are correct
- Port issues:
  - Make sure service is set to expose 8188 and map 8188:8188
  - Confirm no firewall blocks the port
- GPU issues:
  - Confirm GPU is enabled for the service and on the host
  - Verify `nvidia-smi` works on the host; ensure NVIDIA Container Toolkit is installed
- Volume mounts:
  - Ensure host folders exist and have correct permissions
  - Check that models are placed under `/workspace/ComfyUI/models` subfolders (as ComfyUI expects)

## Notes

- Ignore docker-compose.yml for Coolify; it’s not needed here and mentions SwarmUI ports.
- The container mirrors the RunPod-style install inside `Comfy_UI_V45.zip` so behavior matches RunPod’s environment.

## Useful links

- ComfyUI: https://github.com/comfyanonymous/ComfyUI
- SwarmUI: https://github.com/mcmonkeyprojects/SwarmUI
- Coolify: https://coolify.io/docs
- Docker: https://docs.docker.com/