cd /workspace

git clone https://github.com/comfyanonymous/ComfyUI

cd /workspace/ComfyUI

git reset --hard

git stash

git pull --force

python -m venv venv

source venv/bin/activate

python -m pip install --upgrade pip

pip install -r requirements.txt

pip uninstall torch torchvision xformers torchaudio --yes

pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl

pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl

pip install https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/xformers-0.0.30+3abeaa9e.d20250427-cp310-cp310-linux_x86_64.whl

pip install insightface

pip install onnxruntime-gpu

cd /workspace/ComfyUI/custom_nodes

git clone https://github.com/ltdrdata/ComfyUI-Manager

git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus

git clone https://github.com/Gourieff/ComfyUI-ReActor

git clone https://github.com/city96/ComfyUI-GGUF

cd ComfyUI-GGUF

git reset --hard

git stash

git pull --force

cd ..

cd ComfyUI-Manager

git reset --hard

git stash

git pull --force

cd ..

cd ComfyUI-ReActor

python install.py

cd ..

git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack

cd ComfyUI-Impact-Pack

python install.py

pip install piexif

cd /workspace/ComfyUI

cd /workspace

pip install requests

apt update

apt install psmisc

pip install triton

pip install deepspeed

pip install huggingface_hub hf_transfer

pip install accelerate

pip install diffusers

cd /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF

pip install -r requirements.txt

export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_CHUNK_CACHE_SIZE_BYTES=90737418240

cd /workspace

python Download_Reactor_Models.py

