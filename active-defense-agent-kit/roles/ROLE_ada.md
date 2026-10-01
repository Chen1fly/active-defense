# ROLE: ada（RTX 6000 Ada · 渲染）

你负责在 CARLA 中构建场景并采集多视角网格，产出 $DATA_ROOT/scenes/scene_000/，格式严格按 SPEC 第 4、5 节。你不运行 VLM，也不评估准确率。

## 第 1 周
1. 环境：安装 CARLA 0.9.14，离屏模式（-RenderOffScreen）运行，确认 RGB 相机出图。环境导出到 env/lock_ada.txt。
2. 场景（同步模式，世界完全静止，所有视角下除相机外场景内容完全相同）：
   - Town04 中选一个有人行横道的路段
   - 一名静止行人站在人行横道中间，姿态冻结
   - 路边放置一块 1m x 1m 的平面广告板（优先 blueprint 库中的公交站或广告类 static prop，没有就用平面 prop），板面大致朝向来车方向；要求在 nominal_vp 清晰可见且不遮挡行人
   - 天气 ClearNoon，记录到 scene_meta.json
3. 相机：1920x1080，FOV 90，安装在 ego 车辆车顶前部（参数自定并写入 scene_meta.json）。按 SPEC 第 5 节的 150 个视角逐一设置 ego 位置与相机朝向（车头始终沿车道，yaw/pitch 只作用于相机），每个视角采集 RGB、深度、语义分割。
4. 每个视角计算：
   - 广告板 4 角世界坐标投影到图像 → panel_corners_px
   - 深度遮挡判断 → panel_mask.png、panel_visible_px
   - 语义分割中行人像素数 → ped_visible_px，按 SPEC 规则写 gt
5. splits.json：在 panel_visible_px > 0 的视角中，seed=0 随机取 40% 作为 attack_train_vps。
6. common/validate.py 可用后（a100 第 1 天任务），用它校验整个 scene_000。
7. 自检图（存 reports/ada/figs/）：
   - 贴合检查：把一张纯色图按 panel_corners_px 单应变换贴回 5 个代表性视角，叠加显示
   - contact sheet A：yaw=0 时按 dist x lateral 排列的缩略图
   - contact sheet B：nominal_vp 位置 5 个 yaw 的缩略图
   - 统计表：每个视角的 ped_visible_px、panel_visible_px、action_gt

## 第 2 周
等人审核第 1 周自检图。审核通过后按人的决定扩展场景配置（天气、位置等）；没有指示前不要自行扩展。

## 交付物
- $DATA_ROOT/scenes/scene_000/（通过 validate）
- reports/ada/week1.md + 自检图

## 注意
- 如果找不到满足条件的位置，或者大量视角中行人不可见、广告板不可见，不要改网格或广告板尺寸，写进“待人决定”。
