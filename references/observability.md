# Juanjuan Team 可观测性规范

**用途**：把"对抗式协作"从 Agent 自觉变成可观测的 trace 文件。借鉴 hermes-studio 的 `run_id` 机制，但落地到 Phase 层而非 reply 层。

**核心理念**：没有 trace，就没有对抗证据。

---

## 一、run_id 规范

### 1.1 格式

```
run-<phase>-<YYYYMMDDHHmm>-<rand4>
```

例：`run-4-20260804-1430-a3f2`

- `phase`：Phase 编号（0/0.5/1/2/.../11）
- `YYYYMMDDHHmm`：本地时间戳，分钟级
- `rand4`：4 位随机十六进制，避免同一分钟撞名

### 1.2 生成时机

每个 Phase 开始时由 convener 生成一个 run_id，写入 `.phase-trace.json` 的 `runs` 数组。

### 1.3 传播规则

run_id 出现在以下位置：
- `.msg/<from>_<to>_Phase<N>_<ts>.json` 的 `run_id` 字段
- `.msg/<to>_<from>_Phase<N>_<ts>.ack.json` 的 `run_id` 字段
- Phase 产出的 spec 文档、代码 commit message、备份文件名（可选）
- `.phase-trace.json` 的对应 run 条目

---

## 二、phase-trace.json

### 2.1 文件位置

`<项目目录>/.phase-trace.json`

### 2.2 结构

```json
{
  "task_id": "<项目目录名>",
  "created_at": "<ISO 8601>",
  "updated_at": "<ISO 8601>",
  "runs": [
    {
      "run_id": "run-0-20260804-1430-a3f2",
      "phase": "Phase 0",
      "phase_name": "头脑风暴",
      "agent": "convener",
      "started_at": "<ISO 8601>",
      "ended_at": "<ISO 8601>",
      "outcome": "completed | failed | skipped",
      "artifacts": [
        ".msg/convener_docs-researcher_Phase0_<ts>.json"
      ]
    },
    {
      "run_id": "run-4-20260804-1435-b1c2",
      "phase": "Phase 4",
      "phase_name": "方案审核",
      "agent": "convener",
      "started_at": "<ISO 8601>",
      "ended_at": "<ISO 8601>",
      "outcome": "completed",
      "parallel_evidence": {
        "architect_request_ts": "<ISO 8601>",
        "reviewer_request_ts": "<ISO 8601>",
        "docs_researcher_request_ts": "<ISO 8601>",
        "parallel": true,
        "time_delta_ms": 120
      },
      "decision_level": "LEVEL_B",
      "recommended_solution": "B",
      "weighted_scores": {"A": 82.0, "B": 84.75, "C": 79.25}
    }
  ],
  "current_run_id": null,
  "current_phase": "Phase 11"
}
```

### 2.3 更新规则

- Phase 开始：append 一个新 run，`current_run_id` 指向它
- Phase 结束：更新该 run 的 `ended_at` 和 `outcome`，`current_run_id` 设为 null
- Phase 失败：标记 `outcome: "failed"`，触发回退（state-machine.md §三）

---

## 三、decision-trace.json（可选）

记录 Phase 4 对抗式辩论的全过程：

```json
{
  "run_id": "run-4-20260804-1435-b1c2",
  "proposals": [
    {"id": "A", "architect_reasoning": "...", "reviewer_critique": "...", "score": 82.0},
    {"id": "B", "architect_reasoning": "...", "reviewer_critique": "...", "score": 84.75}
  ],
  "optimizer_improvements": "...",
  "judge_verdict": "...",
  "final_decision": "B",
  "level": "LEVEL_B"
}
```

---

## 四、rolling phase summary

### 4.1 文件位置

`<项目目录>/.phase-summary.md`

### 4.2 更新时机

每完成一个 Phase，docs-researcher 更新此文件。借鉴 hermes-studio 的 rolling room summary 思路。

### 4.3 格式

```markdown
# Phase Summary (juanjuan-team)

## Phase 0: 头脑风暴
- **run_id**: run-0-20260804-1430-a3f2
- **需求**: <一句话描述>
- **关键决策**: <澄清了什么>

## Phase 4: 方案审核
- **run_id**: run-4-20260804-1435-b1c2
- **评估方案**: A/B/C
- **选定**: B (LEVEL B, 84.75 分)
- **风险**: <列>
- **Optimizer 改进**: <architect 转的角色>

## Phase 8: 代码审查
- **run_id**: run-8-20260804-1500-c4d5
- **verdict**: pass
- **覆盖率**: 85%
- **OWASP**: 逐条命中情况
```

### 4.4 用途

- Phase 0.5 docs-researcher 查 memory 时优先读此文件，不用全量查 ruflo memory
- 卷卷可随时打开看当前进度
- 元验证 MV-1/MV-2 可从此文件追溯证据

---

## 五、消息字段扩展

`.msg/*.json` 文件在原有字段基础上加 `run_id`：

```json
{
  "id": "<uuid>",
  "run_id": "run-4-20260804-1435-b1c2",
  "from": "convener",
  "to": "architect",
  "phase": "Phase 4",
  "type": "request | response | broadcast",
  "payload": {},
  "timestamp": "<ISO 8601>",
  "ack": false
}
```

`run_id` 必填。无 run_id 的消息视为 legacy，元验证容错处理。

---

## 六、与 hermes-studio 的对比

| 维度 | hermes-studio | juanjuan-team |
|------|---------------|---------------|
| run_id 粒度 | 每 agent reply 一个 | 每 Phase 一个 |
| 绑定内容 | assistant parts + tool rows | 消息 + 产出物 + 审核意见 |
| 持久化 | DB 表 | JSON 文件（.phase-trace.json） |
| summary 触发 | human-turn interval | Phase 结束 |
| summary 更新者 | bare isolated Ekko agent | docs-researcher |

---

## 七、向后兼容

### 7.1 旧项目无 run_id

`meta-verify.sh` 兼容：检测到 `.msg/*.json` 无 `run_id` 字段时，标记为 `legacy_mode: true`，跳过 MV-1/MV-2 的 run_id 相关检查，仅做时间戳独立性检查。

### 7.2 升级路径

旧项目可手动在 `.phase-trace.json` 加 `legacy: true` 字段，明示这是 v1.4 前项目。
