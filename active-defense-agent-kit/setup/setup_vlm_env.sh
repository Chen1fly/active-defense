#!/bin/bash
# 由人在 A100 节点上运行一次（H200 若也能访问 /lustre，则直接复用同一环境，无需重装）
# 集群若需要先加载模块，请先执行例如：module load miniconda3（以你们集群实际模块名为准）
set -euo pipefail

export DATA_ROOT=/lustre/hdd/LAS/cmiao-lab/chenyf/EOT-TRY
export HF_HOME=$DATA_ROOT/models/hf
mkdir -p $DATA_ROOT/{scenes,patches,feedback,models/hf,envs}

# 1. 环境（建在 /lustre 上，A100 与 H200 共用同一份）
conda create -y -p $DATA_ROOT/envs/eot python=3.10
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $DATA_ROOT/envs/eot

pip install torch==2.5.1 torchvision==0.20.1 --index-url https://download.pytorch.org/whl/cu124
pip install transformers==4.51.3 accelerate==1.6.0 kornia pillow numpy pandas matplotlib

# 2. 锁定模型版本并下载
python - << 'PY'
from huggingface_hub import HfApi, snapshot_download
repo = "Qwen/Qwen2.5-VL-7B-Instruct"
sha = HfApi().model_info(repo).sha
snapshot_download(repo, revision=sha)
snapshot_download("openai/clip-vit-large-patch14")
import sys, torch, transformers
print("=================== 把下面这些填进 SPEC.md ===================")
print("COMMIT_HASH =", sha)
print("python      =", sys.version.split()[0])
print("torch       =", torch.__version__, "| cuda available:", torch.cuda.is_available())
print("transformers=", transformers.__version__)
if torch.cuda.is_available():
    print("GPU         =", torch.cuda.get_device_name(0))
PY

# 3. 导出完整依赖清单（放进仓库 env/lock_vlm.txt 并提交）
pip freeze > $DATA_ROOT/lock_vlm.txt
echo "依赖清单已写入 $DATA_ROOT/lock_vlm.txt，请复制到仓库 env/lock_vlm.txt"
