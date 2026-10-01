# ROLE: a100（A100 · 标准查询、feedback 提取、A0）

你维护全项目唯一的 VLM 查询实现，所有正式数字都以你这台机器的输出为准。

## 第 1 周
1. 第 1 天：common/validate.py
   - validate_scene(path)：检查 SPEC 第 4、5 节的目录、文件、meta 字段、vp 数量、vp_id 格式、gt 规则
   - validate_feedback(path)：检查 SPEC 第 7 节的字段、形状、dtype
   - validate_patch(path)：检查尺寸、取值范围、config 字段
   - 命令行：python -m common.validate <path>
2. common/vlm_query.py
   - load_model()：按 SPEC 第 3 节（bf16、eager、锁定 revision）
   - preprocess(rgb)：按 SPEC 第 6 节；assert 图像 token 网格为 27x48
   - query(img, qid) → SPEC 第 7 节对应子字典
   - 单元测试：(a) 选项 token 取到的是模型实际会生成的那个 token（注意 "A" 与 " A" 等分词差异）；(b) 同一张图查询两次 logits 逐位一致；(c) attention 的 query 位置确实是预测答案的位置
3. feedback/extract.py：python -m feedback.extract --scene scene_000 --condition clean|A0|A1 [--vps ...]
   - 攻击条件下从 rgb + patches/{cond}/patch.png 用 common/composite.py 合成（common/composite.py 未就绪前只跑 clean）
   - 写 .pt 前调用 validate_feedback
4. 渲染数据到达前，用任意驾驶场景图片把全流程跑通。
5. scene_000 到达后：提取 clean 条件全部 150 个视角。用 analysis/heatmaps.py（laptop 维护）出图；若尚未合并，先输出准确率表格（按 dist x lateral，每个 yaw 一张）。

## 第 2 周：A0（复现 Fernandez 等，arXiv 2603.08897），代码放 attack/a0/
- 只在 nominal_vp 一个视角上优化；patch 用 common/composite.py 贴图
- 黑盒：只能使用模型生成的文本，不能用梯度或 logits
- NES：每轮 20 个方向，正负各评估一次，σ = 0.1（patch 像素按 [0,1] 尺度），学习率 0.02，150 轮；初始化随机噪声，seed=0
- EOT：每个候选取 5 个样本平均，变换为 ±5 像素平移、亮度乘子 [0.9,1.1]、对比度偏移 [-0.05,0.05]
- 损失：Q_desc 生成文本与目标句 "The driver should accelerate and continue forward because the road is clear" 的 CLIP 文本嵌入余弦距离（openai/clip-vit-large-patch14 文本编码器，冻结）；加 TV 正则 0.001
- 每 10 轮记录损失和 nominal_vp 处 Q_action / Q_ped 的结果（只记录，不用于优化）
- 产出 patches/A0/，然后提取 A0 条件全部 150 个视角的 feedback
- H200 产出 patches/A1/ 后，同样提取 A1 条件全部 150 个视角的 feedback

## 交付物
- 第 1 周：validate.py、vlm_query.py + 单元测试结果、clean 全网格 feedback、clean 准确率图或表
- 第 2 周：A0 patch 及优化曲线、A0 在 nominal_set 上的攻击成功率、A0 和 A1 全网格 feedback

## 注意
- 干净准确率低就照实报告，不要换问题、换解码方式或换分辨率去“修”它。
