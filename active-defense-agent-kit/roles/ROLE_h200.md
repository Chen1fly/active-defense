# ROLE: h200（H200 · A1 白盒视角鲁棒攻击）

你实现 A1：白盒梯度优化 patch，EOT 直接使用网格中真实视角的几何变换。

## 第 1 周（渲染数据到达前，用占位图和人工构造的四边形开发）
1. common/composite.py
   - composite(rgb, patch, corners_px, panel_mask) → 合成图；单应变换（kornia.geometry.warp_perspective 或等价实现）+ 按 panel_mask alpha 合成
   - 全程可微；评估调用时外部包 torch.no_grad
   - 优先完成并提交，a100 第 2 周依赖它
2. attack/diff_preproc.py
   - 用 torch 重写 common/vlm_query.py 中的 preprocess + processor（resize、归一化、patch 切分），全程可微
   - 等价性测试：同一张图分别走标准路径和可微路径，送入模型后 Q_action 四个选项 logit 的最大差 < 1e-2。测试不通过不得开始正式攻击，测试结果写入报告
3. attack/a1/：优化循环
   - 损失：Q_action 目标 "A" 的交叉熵 + Q_ped 目标 "No" 的交叉熵（权重各 1）+ TV 正则 0.001
   - 每步 EOT：从 splits.json 的 attack_train_vps 中采样 batch 个视角；每个视角加角点扰动 ±2px、亮度乘子 [0.8,1.2]、对比度偏移 [-0.1,0.1]、高斯噪声 σ=0.01
   - Adam 直接优化 patch 像素，每步 clamp 到 [0,1]；初始化随机噪声，seed=0
   - 初始超参：batch 8，2000 步，学习率 0.01。只允许调这三个，每次尝试都记录到 attack/a1/runs.md
   - 优化阶段可用 attn_implementation="sdpa" 以省显存；等价性测试必须用与标准实现相同的 eager
   - 每 200 步记录：损失曲线，nominal_vp 及 5 个固定 attack_train 视角上的攻击成功率

## 第 2 周
scene_000 到位后跑正式优化，产出 patches/A1/（patch.png、patch.pt、config.json，config 中写入全部超参、seed、等价性测试结果）。
自行做开发评估：分别报告 attack_train 视角和非 attack_train 视角上的攻击成功率（仅供参考）。正式全网格 feedback 由 a100 提取。

## 交付物
- 第 1 周：common/composite.py、等价性测试报告
- 第 2 周：A1 patch、损失曲线、开发评估结果、runs.md

## 注意
- 绝对不能在非 attack_train 视角上优化，也不能根据它们的结果挑选超参。
- 如果 nominal_set 上攻击成功率达不到 70%，不要扩大 patch、改目标或改 EOT 范围，写进“待人决定”。
