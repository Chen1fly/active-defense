# 启动说明（给人看）

## 一次性准备（全部是命令，不需要再改任何文档，除了第 2 步的一个 hash）

1. 在 A100 节点上运行环境脚本：
   bash setup/setup_vlm_env.sh

2. 把脚本最后打印的 COMMIT_HASH 填进 SPEC.md 第 3 节的 {COMMIT_HASH}（这是唯一要手改的地方）。
   若打印的 python/torch/transformers 版本与 SPEC 第 3 节不一致，先停下来找导师。

3. 建共享仓库和四个工作目录（在任意一台能访问 /lustre 的机器上执行一次）：
   export DATA_ROOT=/lustre/hdd/LAS/cmiao-lab/chenyf/EOT-TRY
   git init --bare $DATA_ROOT/repo.git
   git clone $DATA_ROOT/repo.git $DATA_ROOT/work/main
   cd $DATA_ROOT/work/main
   cp -r <解压后的 active-defense-agent-kit>/{SPEC.md,roles,status,setup} .
   mkdir -p env && cp $DATA_ROOT/lock_vlm.txt env/lock_vlm.txt
   git add . && git commit -m "init spec" && git branch -M main && git push -u origin main
   for r in ada a100 h200 laptop; do
     git clone $DATA_ROOT/repo.git $DATA_ROOT/work/$r
     (cd $DATA_ROOT/work/$r && git checkout -b role/$r && git push -u origin role/$r)
   done

4. 每台机器上的 agent 在各自目录启动：
   6000 Ada → $DATA_ROOT/work/ada
   A100     → $DATA_ROOT/work/a100
   H200     → $DATA_ROOT/work/h200
   笔记本   → $DATA_ROOT/work/laptop
   work/main 只给你自己用来合并分支，agent 不进入。

## 每台机器给 agent 的提示词（每次新会话都用这一句，只改角色名）

6000 Ada：
你的角色是 ada。开始工作前依次阅读 SPEC.md、roles/ROLE_ada.md、status/ada.md，然后从 status 的“下一步”继续。严格遵守 SPEC 第 9–11 节。

A100：
你的角色是 a100。开始工作前依次阅读 SPEC.md、roles/ROLE_a100.md、status/a100.md，然后从 status 的“下一步”继续。严格遵守 SPEC 第 9–11 节。

H200：
你的角色是 h200。开始工作前依次阅读 SPEC.md、roles/ROLE_h200.md、status/h200.md，然后从 status 的“下一步”继续。严格遵守 SPEC 第 9–11 节。

笔记本：
你的角色是 laptop。开始工作前依次阅读 SPEC.md、roles/ROLE_laptop.md、status/laptop.md，然后从 status 的“下一步”继续。严格遵守 SPEC 第 9–11 节。

## 依赖顺序
- a100 第 1 天的 validate.py → 其他人都要用
- h200 的 common/composite.py → a100 第 2 周的 A0 和攻击条件 feedback 提取要用
- ada 的 scene_000 → a100 的 clean 提取、h200 的 A1 正式优化
- a100 的全网格 feedback → laptop 的真实分析
