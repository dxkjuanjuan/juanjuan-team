# Juanjuan Team Agent 间消息协议

**用途**：定义 7 个 Agent 之间的通信原语，避免「Agent 起来后不会对话」。

---

## 一、通信原语

### 1.1 文件消息（推荐）

Agent 间通过写文件 + 轮询通信：

```
<项目目录>/.msg/<from>_<to>_<phase>_<timestamp>.json
```

格式：
```json
{
  "id": "<uuid>",
  "from": "convener",
  "to": "architect",
  "phase": "Phase 4",
  "type": "request | response | broadcast",
  "payload": {},
  "timestamp": "<ISO 8601>",
  "ack": false
}
```

### 1.2 MCP 工具（如可用）

| 工具 | 用途 |
|------|------|
| `mcp__claude-flow__agent_execute` | 给 Agent 派任务（同步或异步） |
| `mcp__claude-flow__swarm_status` | 查 swarm 状态（含 Agent 心跳） |
| `mcp__claude-flow__hive-mind_broadcast` | 广播消息给所有 Agent |
| `mcp__claude-flow__hive-mind_consensus` | YOLO 模式投票 |

### 1.3 SendMessage（Claude Code 原生）

Convener 用 `SendMessage({ to: "agent-name", message: "..." })` 给 named agent 发消息。

---

## 二、每个 Phase 的消息契约

### Phase 0 → 0.5（并行启动）

- **convener** 启动 brainstorming 同时，写 `.msg/convener_docs-researcher_Phase0_<ts>.json`
- **docs-researcher** 收到后开始 memory_search + kimi-webbridge
- **docs-researcher** 完成后写 `.msg/docs-researcher_convener_Phase0.5_<ts>.json`（结果）
- **convener** brainstorming 完成后读这个文件作为 Phase 1 输入

### Phase 1 → 2

- **convener** 用 AskUserQuestion 让卷卷选模式
- 选完后写 `.msg/convener_all_Phase1_<ts>.json`（broadcast 模式选择结果）

### Phase 3 → 4

- **convener + architect** 出方案 A/B/C
- **convener** 写 3 个文件（统一带 `<ts>` 后缀）：
  - `.msg/convener_architect_Phase4_<ts>.json`
  - `.msg/convener_reviewer_Phase4_<ts>.json`
  - `.msg/convener_docs-researcher_Phase4_<ts>.json`
- **三方并行审核**（各自独立，不看对方）
- 三方完成后各写 `.msg/<role>_convener_Phase4_<ts>.json`（审核意见）

### Phase 4 → 5

- **convener** 读三方意见，加权评分，写 `.msg/convener_leader_Phase4_<ts>.json`（汇总 + LEVEL）
- **leader** 裁决后写 `.msg/leader_convener_Phase4_<ts>.json`（verdict）

### Phase 7 → 8

- **architect** 写接口契约到 `<项目>/contracts/`
- **frontend + coder** 并行实施，完成后写 `.msg/<role>_reviewer_Phase8_<ts>.json`
- **reviewer** 收到后开始代码审查

### Phase 8 → 9

- **reviewer** 写 `.msg/reviewer_convener_Phase8_<ts>.json`（verdict + pass/reject）
- **convener** 收到 pass 触发备份（Phase 9 事件驱动）

---

## 三、ACK 与超时

### 3.1 ACK 机制

每条消息收到后接收方必须写一个 ack 文件：
```
.msg/<to>_<from>_<phase>_<ts>.ack.json
{ "ack": true, "timestamp": "<ISO 8601>" }
```

### 3.2 超时阈值（按 Phase）

| Phase | 超时 |
|-------|------|
| Phase 0.5 查询 | 120s |
| Phase 3 方案生成 | 300s |
| Phase 4 三方审核 | 600s |
| Phase 7 实施 | 1800s |
| Phase 8 代码审查 | 600s |

### 3.3 失联判定

- convener 每 60s 调一次 `swarm_status`
- 连续 3 次无心跳（~180s）判失联
- 失联后本地重试 1 次
- 仍失败按错误降级链路上报

---

## 四、Phase 4 三方并行审核的同步原语

```
convener 同时发起 3 个 agent_execute（异步）:
  - agent_execute(architect_id, "审方案 A/B/C 的技术可行性")
  - agent_execute(reviewer_id, "审方案 A/B/C 的安全/质量")
  - agent_execute(docs-researcher_id, "查是否有历史坑")

convener 等待 3 个 task 都完成（barrier）：
  while not all_acked():
    sleep(10s)
    check swarm_status
    if timeout: handle_failed_agents()

收集 3 份意见 → 加权评分 → LEVEL A/B/C/D
```

---

## 五、消息持久化

所有 `.msg/` 文件项目完成后归档到 `.backups/messages/`，用于：
- 回溯调试（出问题时看消息流）
- 经验存档（存到 ruflo memory 时附消息摘要）
