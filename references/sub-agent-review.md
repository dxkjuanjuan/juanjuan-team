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

2. **平行产出**（v1.7 修正时间戳语义）：主 Agent 自己审的同时派 sub-agent 并行审。判定锚定的标准是**发起时间**：
   - 主 Agent self 的 `started_at` 必须早于或同时与 sub-agent 调用的 `started_at`（差值 ≤ 1 秒）
   - 即 `sub_started_at - self_started_at >= -1`（sub 可以比 self 晚任意时间，但不能比 self 早超过 1 秒）
   - 若 sub 比 self 早超过 1 秒，说明主 Agent 可能先看了 sub 才写自己 → 锚定风险

3. **verdict 必须分类 finding**：
   - **共识**（consensus）：≥2 方都报**同一 issue**（按 §二之 2.1 粒度规则判定"同一"） → 高置信，直接采纳
   - **分歧**（divergence）：只有 1 方报但其他方未确认 → 标记讨论，主 Agent 裁决是否采纳
   - **盲点**（blind_spot）：sub-agent 报了主 Agent 漏的 → 主 Agent 必须明示"我漏了 X，sub-agent-Y 补的"，**不能悄悄采纳**

4. **盲点披露义务**（v1.7 强制内容规范）：主 Agent 若采纳了 sub-agent 报的、自己漏的 issue，必须在 verdict 的 `blind_spots[].acknowledgement` 字段中明示。**acknowledgement 字段必须含以下关键词之一**：
   - "我漏了"
   - "我遗漏了"
   - "主 Agent 漏"
   - "主Agent漏"

   仅写 "ok" / "已采纳" 等空话视为不合格，MV-6 检查会报警。

5. **sub-agent 只产 issue list**：不做最终 verdict，verdict 永远由主 Agent 做。

6. **主 Agent 必须参与**：主 Agent 不能只派 sub-agent 然后干等汇总——必须自己也独立审一遍。

7. **sub-agent 不与卷卷对话**：sub-agent 产出只给主 Agent。

8. **sub-agent 不产生副作用**：sub-agent 只读不写，不能改文件、不能 commit。

9. **sub-agent 不能再 spawn 子 sub-agent**（v1.7 新增）：sub-agent 不能再派自己的 sub-sub-agent，避免 sub-agent 树无限生长导致 token 爆炸。sub-agent 是审核终端节点。

---

## 2.1 issue 粒度规范（v1.7 新增）

为解决"主 Agent 报 X 函数有 SQL 注入" vs "sub-1 报 X 函数有注入风险"算不算共识的问题，统一粒度：

| 审核类型 | 粒度 | 同一 issue 判定 |
|---------|------|---------------|
| 代码审查（Phase 8） | 文件 + 函数/方法名 + issue 类别 | 同一文件 + 同一函数 + 同一类别 = 同一 issue |
| 方案审查（Phase 4） | 方案编号 + 维度（可行性/安全/成本等） | 同一方案 + 同一维度 = 同一 issue |
| 文档审查（Phase 6） | 文档章节号 + issue 类别 | 同一章节 + 同一类别 = 同一 issue |

issue 类别按 `domain-checklists.md` 的 9 信号组（Correctness / Security / Performance / Maintainability / Accessibility / Error Handling / Test Coverage / API Design / Documentation）。

**示例**：
- 主 Agent 报 `{file: "login.ts", function: "authUser", category: "Security", desc: "SQL注入"}` 
- sub-1 报 `{file: "login.ts", function: "authUser", category: "Security", desc: "注入风险"}`
- 粒度判定：同文件 + 同函数 + 同类别（Security）= **同一 issue** → 共识 ✓

**反例**：
- 主 Agent 报 `{file: "login.ts", function: "authUser", category: "Security"}`
- sub-1 报 `{file: "login.ts", function: "authUser", category: "Performance"}`
- 不同类别 = **不同 issue** → 各自记录，不算共识

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
| leader | **0 个**（v1.7 移除） | 裁决有无明显对错（主 Agent 自己审） | ~~原配 1 个 sub-agent 审 leader 拍脑袋~~ v1.7 移除：leader 不做产出，sub-agent 审 leader 内部推理拿不到信号，形同虚设。改为：leader 裁决由 architect 做 peer review（架构师审裁决合理性），不算 sub-agent |
| **总计** | **17 个 sub-agent**（v1.7：原 18 减 1） | + 7 个主 Agent | = 24 路独立审查 |

### 3.1 模式感知

| 模式 | sub-agent 数量 | 主 Agent 是否参与 |
|------|--------------|---------------|
| Safe | 全配置（17 个） | 必须参与 |
| Manual | 全配置（17 个） | 必须参与 |
| Auto | 减半（reviewer 4→2，其他各减 1） | 必须参与 |
| YOLO | 最小（reviewer 2，其他各 1） | 必须参与（不可省） |
| Lite | 仅 reviewer 派 1 个 | reviewer 必须参与 |

### 3.2 主 Agent 不参与的例外

**无例外**。任何模式下主 Agent 都必须自己独立审一遍，否则违反"双层对抗"原则。

---

## 十一、复杂度感知配置（v1.7 新增）

v1.6 写死"Safe 全配 17 个"导致简单任务也被强制 24 路审查，浪费 token。v1.7 改为按任务复杂度自动调整：

| 任务复杂度 | 判定标准 | sub-agent 配置 | 总审查路数 |
|----------|---------|--------------|----------|
| **Lite**（单文件小任务） | 单文件 + 不跨模块 + 无架构影响 + 无新功能 | 仅 reviewer 派 1 个 | 2 路（reviewer + 1 sub） |
| **中等**（2-5 文件） | 2-5 文件 或 跨 1-2 模块 | 每主 Agent 派 1 个（共 6 个，leader 不派） | 12 路（6 主 + 6 sub） |
| **复杂**（>5 文件 / 跨模块 / 新功能） | >5 文件 或 跨 ≥3 模块 或 新功能 或 架构影响 | 按模式配置（Safe 17 / Auto 9 / YOLO 6） | 13-24 路 |

### 11.1 复杂度判定时机

convener 在 Phase 0 头脑风暴时判定复杂度（基于任务描述 + 早期信息），写入 `.phase-trace.json`：

```json
{
  "complexity": "Lite | Medium | Complex",
  "complexity_reasoning": "<判定依据>",
  "sub_agent_config": "lite | medium | full"
}
```

### 11.2 复杂度切换

任务执行中发现复杂度评估错误：
- **低估**（Lite → Complex）：convener 通知团队，按新复杂度增派 sub-agent，已完成的不重审
- **高估**（Complex → Lite）：convener 不撤已派 sub-agent（已花 token），后续 Phase 按新复杂度

### 11.3 卷卷可强制覆盖

卷卷可显式说"用全配置" / "用最小配置"覆盖自动判定。

---

## 四、调用证据

每次 sub-agent 调用产生记录到 `.msg/sub-calls/`：

```
<项目目录>/.msg/sub-calls/<parent>_<subagent_type>_Phase<N>_<ts>.json
```

格式（v1.7 加 token_used 字段）：
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
  "status": "completed | failed",
  "fallback": "主 Agent 接管 | null",
  "fallback_reason": "<若 failed>",
  "token_used": {
    "input": 1234,
    "output": 567,
    "total": 1801
  }
}
```

主 Agent 自己的 finding 也写到 `.msg/<parent>_self_Phase<N>_<ts>.json`，格式相同但 `parent_agent` 和 `reviewer_agent` 都是同一个主 Agent，`source` 字段标 `"self"` 或 `"fallback-from-subagent-X"`。

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

## 八、失败处理（v1.7 详细化）

### 8.1 sub-agent 调用失败

```
sub-agent 调用失败
  ↓
主 Agent 重试 1 次（换更明确的任务描述）
  ↓ 仍失败
主 Agent 自己接管该子任务（不算甩锅，算降级）
  ↓
在 sub-call 记录中标注:
  status: "failed"
  fallback: "主 Agent 接管"
  fallback_reason: "<具体原因>"
  ↓
接管的 finding 仍写到 .msg/<parent>_self_*.json
标注 source: "fallback-from-subagent-X"
  ↓
继续流程，不阻塞
```

### 8.2 主 Agent 自己也失败

```
主 Agent 自己审失败（sub 已派但主 Agent self 写不出）
  ↓
主 Agent 重试 1 次
  ↓ 仍失败
上报 convener，标注"双层对抗失效"
  ↓
convener 决定：
  - 回退到上一 Phase 重新审核
  - 或转卷卷定夺
  - 或降级为单层审核（仅 sub-agent），明示"主 Agent 失联，仅 sub-agent 审核"
```

### 8.3 sub-agent 和主 Agent 都失败

罕见但可能（如 ruflo MCP 整体挂）：
- convener 标注"Phase N 审核完全失效"
- 强制回退到 Phase 0 重做
- 不允许跳过审核继续

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
