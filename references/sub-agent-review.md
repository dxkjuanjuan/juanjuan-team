# Juanjuan Team Sub-Agent 双层对抗审核规范（v1.6）

**用途**：把对抗式协作从"主 Agent 自觉"升级为"主 Agent + sub-agent 平行独立审 + 三方综合"。主 Agent 不是监督 sub-agent，而是和 sub-agent 平起平坐地独立审，最后做比对、筛选、综合。

**核心理念**：主 Agent 自己也会犯错——让 sub-agent 独立审一遍，与主 Agent 的判断**平行比对**，发现主 Agent 的盲点和误判。主 Agent 不能只做汇总员。

---

## 一、设计图（核心）

```
                   被审产出（如方案 A/B/C）
                          ↓
            ┌─────────────┼─────────────┐
            ↓             ↓             ↓
       主 Agent       sub-agent-1    sub-agent-2 ...
       独立审         独立审          独立审
       (同时发起，互不看对方)
            ↓             ↓             ↓
       finding_主      finding_sub1    finding_sub2
            └─────────────┼─────────────┘
                          ↓
                  【比对阶段】
                  - 找共识：三方都提到的 issue → 高置信
                  - 找分歧：只有一方提到的 → 标记讨论
                  - 找盲点：sub-agent 报了主 Agent 漏的 → 标记盲点
                          ↓
                  【筛选阶段】
                  - 去重（多方都报的合并）
                  - 降级（sub-agent 误报的剔除）
                  - 升级（多方都报的提严重度）
                          ↓
                  【综合阶段】
                  主 Agent 综合 finding 做 verdict
                  verdict 必须分类：
                  - 三方共识
                  - 分歧点 + 如何裁决
                  - 盲点（主 Agent 漏的，sub-agent 补的）
```

---

## 二、关键约束（硬规则）

1. **主 Agent 必须先独立审**：不能先看 sub-agent 的 finding 再写自己的——避免锚定效应。主 Agent 的 finding 和 sub-agent 的 finding 必须**同时发起**，互不看对方。

2. **平行产出**：主 Agent 自己审的同时派 sub-agent 并行审，时间差 ≤ 1 秒发起。主 Agent 不能等 sub-agent 完成后再写自己的。

3. **verdict 必须分类 finding**：
   - **共识**（consensus）：≥2 方都报的 issue → 高置信，直接采纳
   - **分歧**（divergence）：只有 1 方报但其他方未确认 → 标记讨论，主 Agent 裁决是否采纳
   - **盲点**（blind_spot）：sub-agent 报了主 Agent 漏的 → 主 Agent 必须明示"我漏了 X，sub-agent-Y 补的"，**不能悄悄采纳**

4. **盲点披露义务**：主 Agent 若采纳了 sub-agent 报的、自己漏的 issue，必须在 verdict 中明示。悄悄采纳等于偷 sub-agent 的功劳，违反对抗式原则。

5. **sub-agent 只产 issue list**：不做最终 verdict，verdict 永远由主 Agent 做。

6. **主 Agent 必须参与**：主 Agent 不能只派 sub-agent 然后干等汇总——必须自己也独立审一遍。

7. **sub-agent 不与卷卷对话**：sub-agent 产出只给主 Agent。

8. **sub-agent 不产生副作用**：sub-agent 只读不写，不能改文件、不能 commit。

---

## 三、sub-agent 数量与职责

| 主 Agent | sub-agent 数量 | 主 Agent 自己审什么 | sub-agent 各审什么 |
|----------|--------------|------------------|------------------|
| convener | 3 个 | 汇总完整性 + 对外表达清晰度 | sub-1: 漏 issue 检查；sub-2: 主观判断夹带检查；sub-3: 越权（替卷卷做决定）检查 |
| architect | 3 个 | 技术可行性 + tradeoff 全面性 | sub-1: 论据充分性；sub-2: 备选方案遗漏；sub-3: 任务拆解粒度 |
| frontend | 2 个 | shadcn/Ant Design 合规 | sub-1: 可访问性；sub-2: 性能 |
| coder | 3 个 | OWASP Top 10 | sub-1: 测试覆盖；sub-2: immutability/KISS；sub-3: 错误处理完整性 |
| reviewer | 4 个 | OWASP + 测试覆盖率（核心） | sub-1: 语言专项（typescript-reviewer 等）；sub-2: 安全专项（security-reviewer）；sub-3: 静默失败（silent-failure-hunter）；sub-4: 类型设计（type-design-analyzer） |
| docs-researcher | 2 个 | spec 逻辑一致性 | sub-1: 资料来源真实性；sub-2: 边界情况遗漏 |
| leader | 1 个 | 裁决有无明显对错 | sub: 裁决有无拍脑袋（避免主观） |
| **总计** | **18 个 sub-agent** | + 7 个主 Agent | = 25 路独立审查 |

### 3.1 模式感知

| 模式 | sub-agent 数量 | 主 Agent 是否参与 |
|------|--------------|---------------|
| Safe | 全配置（18 个） | 必须参与 |
| Manual | 全配置（18 个） | 必须参与 |
| Auto | 减半（reviewer 4→2，其他各减 1） | 必须参与 |
| YOLO | 最小（reviewer 2，其他各 1） | 必须参与（不可省） |
| Lite | 仅 reviewer 派 1 个 | reviewer 必须参与 |

### 3.2 主 Agent 不参与的例外

**无例外**。任何模式下主 Agent 都必须自己独立审一遍，否则违反"双层对抗"原则。

---

## 四、调用证据

每次 sub-agent 调用产生记录到 `.msg/sub-calls/`：

```
<项目目录>/.msg/sub-calls/<parent>_<subagent_type>_Phase<N>_<ts>.json
```

格式：
```json
{
  "sub_call_id": "<uuid>",
  "run_id": "run-4-20260804-1435-b1c2",
  "parent_agent": "reviewer",
  "subagent_type": "typescript-reviewer",
  "task": "审 src/auth/login.ts 的类型安全",
  "findings": [
    {"severity": "major", "location": "src/auth/login.ts:42", "description": "...", "evidence": "..."}
  ],
  "started_at": "<ISO 8601>",
  "ended_at": "<ISO 8601>",
  "status": "completed | failed"
}
```

主 Agent 自己的 finding 也写到 `.msg/<parent>_self_Phase<N>_<ts>.json`，格式相同但 `parent_agent` 和 `reviewer_agent` 都是同一个主 Agent。

---

## 五、综合阶段输出格式

主 Agent 综合后的 verdict 文档：

```json
{
  "phase": "Phase 8",
  "run_id": "run-8-20260804-1500-c4d5",
  "reviewer_agent": "reviewer",
  "self_findings": [...],
  "sub_agent_findings": {
    "typescript-reviewer": [...],
    "security-reviewer": [...],
    "silent-failure-hunter": [...],
    "type-design-analyzer": [...]
  },
  "consensus": [
    {"issue": "...", "sources": ["self", "security-reviewer", "typescript-reviewer"], "severity": "critical"}
  ],
  "divergence": [
    {"issue": "...", "only_source": "silent-failure-hunter", "verdict": "降级为 minor（误报）", "reasoning": "..."}
  ],
  "blind_spots": [
    {"issue": "...", "source": "type-design-analyzer", "verdict": "采纳，我漏了", "acknowledgement": "主 Agent 明示：我漏了 X，sub-agent-Y 补的"}
  ],
  "final_verdict": "pass | pass_with_conditions | reject",
  "coverage_check": "85%",
  "owasp_check": "..."
}
```

---

## 六、新增元验证 MV-6

在 `meta-verification.md` 已有 MV-1~MV-5 基础上新增：

### MV-6 主+sub 双层对抗验证

**验证目标**：
1. 主 Agent 真的派了 sub-agent
2. 主 Agent 自己也独立审了（不是只汇总）
3. 主 Agent 和 sub-agent 是**平行**产出（不是先看 sub 再写自己）
4. verdict 引用了 sub-agent finding 并分类为共识/分歧/盲点

**验证方式**：
- 检查 `.msg/sub-calls/` 目录，Phase 4/6/8 必须有 sub-agent 调用记录
- 检查 `.msg/<parent>_self_*.json`，主 Agent 自己的 finding 文件必须存在
- 时间戳验证：主 Agent self finding 的 `started_at` 必须 ≤ sub-agent 调用的 `started_at` + 1s（证明是平行发起，不是看完 sub 才写自己）
- verdict 文档必须含 `consensus / divergence / blind_spots` 三类分类
- `blind_spots` 若非空，每条必须有 `acknowledgement` 字段（明示主 Agent 漏了）

**失败动作**：报警"双层对抗验证失败：主 Agent 未参与 / 未平行产出 / 盲点未披露"，标记此 Phase 失败。

---

## 七、与现有 role-*.md 的关系

sub-agent 不是新角色，是主 Agent 的"平行审查员"。主 Agent 的角色定义加一节：

```markdown
## 3. 工作流程（按 Phase）

- **Phase 4/6/8 审核**：
  - v1.6 新增：主 Agent 自己独立审一遍（产 self_findings）
  - v1.6 新增：同时派 N 个 sub-agent 独立审（见 `sub-agent-review.md`）
  - v1.6 新增：综合阶段分类 finding（共识/分歧/盲点），盲点必须明示
  - 最终 verdict 必须引用 finding_id
```

---

## 八、失败处理

```
sub-agent 调用失败
  ↓
主 Agent 重试 1 次（换更明确的任务描述）
  ↓ 仍失败
主 Agent 自己接管该子任务（不算甩锅，算降级）
  ↓
在 sub-call 记录中标注 status: "failed", fallback: "主 Agent 接管"
  ↓
继续流程，不阻塞
```

若主 Agent 自己也失败：
- 上报 convener，标注"双层对抗失效"
- convener 决定是否回退到上一 Phase 或转卷卷

---

## 九、性能权衡

| 维度 | 主+sub 全配 | 仅主（无 sub） | 仅 sub（主不参与，错误） |
|------|-----------|-------------|------------------|
| 准确性 | 最高 | 中 | 中（主 Agent 沦为汇总员） |
| token | 3-5x | 1x | 2-3x |
| 速度 | 慢 | 快 | 中 |
| 盲点检测 | 强 | 无 | 弱 |
| 适用 | 重要项目 | 快速迭代 | ❌ 不允许 |

**推荐**：Safe/Manual 全配，Auto/YOLO 减半，Lite 仅 reviewer 派 1 个 + reviewer 自己审。

---

## 十、反模式

### AP-13 sub-agent 变成形式主义

**症状**：主 Agent 派 sub-agent 但不引用 finding，verdict 自己写。
**预防**：MV-6 检查 verdict 必须引用 finding_id 并分类。

### AP-14 sub-agent 串行调用

**症状**：主 Agent 一个一个串行调 sub-agent。
**预防**：MV-6 检查 sub-call 时间差 ≤ 1 秒。

### AP-15 主 Agent 只做汇总员

**症状**：主 Agent 不自己审，只汇总 sub-agent 的 finding。
**预防**：MV-6 检查 `.msg/<parent>_self_*.json` 必须存在，且时间戳证明是平行产出。

### AP-16 盲点悄悄采纳

**症状**：主 Agent 采纳了 sub-agent 报的、自己漏的 issue，但不明示"我漏了"。
**预防**：MV-6 检查 `blind_spots` 若非空，每条必须有 `acknowledgement` 字段。

### AP-17 锚定效应

**症状**：主 Agent 先看 sub-agent 的 finding 再写自己的，被 sub-agent 误导。
**预防**：MV-6 时间戳验证，主 Agent self finding 必须 ≤ sub-agent 调用 + 1s（证明是平行发起）。
