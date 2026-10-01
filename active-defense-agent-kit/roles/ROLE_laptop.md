# ROLE: laptop（笔记本 CPU · 分析）

你把磁盘上的原始 feedback 变成图表。你不运行模型，只读文件。

## 第 1 周
1. analysis/mock_data.py：按 SPEC 第 4、5、7 节生成格式完全一致的假数据（scene_000，150 个视角，clean/A0/A1），并通过 common/validate.py（就绪后）。
2. analysis/heatmaps.py：python -m analysis.heatmaps --scene scene_000 --condition clean
   - Q_action 准确率、Q_ped 准确率、margin 三种热力图
   - 横轴 dist，纵轴 lateral，每个 yaw 一个子图；action_gt 为 null 的格子标灰
3. analysis/h1.py：python -m analysis.h1 --scene scene_000 --condition A0|A1
   定义（严格按此实现）：
   - 有效视角：action_gt == "C"
   - 起始状态 S：有效视角中 clean 下 Q_action.pred == "C" 且攻击下 != "C"
   - 视角距离：三个维度档位差的绝对值之和
   - k 步可恢复：存在距离 ≤ k 的有效视角 v，使 v 处 clean 和攻击下 Q_action.pred 都等于 "C"
   - 输出 1：k = 1, 2, 3 时 S 中可恢复的比例
   - 输出 2（k=1）：对 s ∈ S，6 个方向中有效的动作按攻击条件下目标视角的 margin 排序，margin 最大者（并列时取集合）为 s 的最优动作；全局最优动作 = 在 S 上平均恢复率最高的方向
     报告 (a) s 的最优动作集合不含全局最优动作的比例；(b) “每个 s 用自己的最优动作”的恢复率 减去 “所有 s 用全局最优动作”的恢复率
   - 输出 3：以上全部结果再按起点的 panel_visible_px 分 3 桶（三分位数）各报告一次
   - 越出网格或落到无效视角的动作，算作未恢复
4. 所有脚本先在 mock 数据上跑通；真实数据到达后只改路径。

## 第 2–3 周
真实 clean、A0、A1 feedback 到齐后运行全部脚本，结果写入 reports/laptop/week{N}.md。

## 交付物
- 可一键运行的 heatmaps.py、h1.py，以及 mock 数据上的示例输出

## 注意
- 遇到上面没覆盖的歧义，选一种处理方式、写清楚，同时列入“待人决定”。
