# Juanjuan Team 容错机制

**用途**：覆盖 happy path 之外的工程化问题——convener 单点、Agent 失联、模式切换原子性、并发隔离。

---

## 一、Convener 单点故障

### 1.1 失联检测

- convener 每 30s 写心跳到 `<项目>/.convener-heartbeat.json`
- leader 每 60s 检查一次，超过 90s 无更新判 convener 失联

### 1.2 Leader 临时接管

convener 失联时：
1. leader 破例临时接管对外窗口（global-rules §二第9条加例外：「convener 失联时 leader 可临时对外，恢复后移交」）
2. leader 读 `.convener-state.json` 恢复状态
3. leader 继续当前 Phase，不重跑已完成 Phase

### 1.3 Convener 状态持久化

`.convener-state.json`:
```json
{
  "current_phase": "Phase 4",
  "mode": "Auto",
  "pending_messages": ["msg-id-1", "msg-id-2"],
  "weighted_scores": { "A": 82, "B": 84 },
  "decision_level": "LEVEL_B",
  "last_heartbeat": "<ISO 8601>"
}
```

每次 Phase 转移时 convener 更新这个文件。

---

## 二、Agent 失联检测

### 2.1 超时阈值

| Phase | 超时 | 检测方式 |
|-------|------|---------|
| Phase 0.5 | 120s | convener 轮询 swarm_status |
| Phase 3 | 300s | convener 轮询 |
| Phase 4 | 600s | barrier 等待 |
| Phase 7 | 1800s | convener 轮询 |
| Phase 8 | 600s | convener 轮询 |

### 2.2 失联处理

```
agent 超时 →
  本地重试 1 次（换更明确任务描述）→
  仍失败 → 上报 convener/leader →
  convener 自己接管该子任务（不算甩锅，算降级）→
  或转卷卷
```

### 2.3 中间产物恢复

失联 Agent 的中间产物存 `<项目>/.agent-recovery/<agent-id>.json`，重启后可恢复。

---

## 三、模式切换原子性

### 3.1 切换点限制

**只在 Phase 边界可切**，Phase 内禁止切（避免半截副作用）。

### 3.2 Phase 边界切换

- 已完成 Phase 的产物全部保留（不回滚）
- 仅影响后续 Phase
- `.mode-switches.json` 记录 `{from, to, at, phase, reason, transaction_id, status: "committed"}`

### 3.3 Phase 内强制切（卷卷要求）

走 saga 模式：
1. 标记受影响文件
2. `git stash` 未 commit 改动
3. 回到 Phase 起点
4. 切换模式
5. 重跑 Phase
6. `.mode-switches.json` 加 `status: "saga-rollback"`

### 3.4 措辞修正

「原子化」实际含义是「Phase 级原子」而非「操作级原子」，文档措辞改为「Phase 边界原子」。

---

## 四、多任务并发隔离

### 4.1 项目目录

加 4 位随机后缀避免撞名：
```
~/项目/YYYY-MM-DD-HHmm-<任务简述>-<rand4>/
```
例：`~/项目/2026-08-04-1430-fix-login-a3f2/`

### 4.2 备份配额

`.daily-counter.json` 是项目内的，每项目独立 3 次/日（YOLO 6 次）。

### 4.3 Ruflo Memory 隔离

- memory key 用项目目录名（含时间戳 + 随机后缀）保证唯一
- namespace=project 下按 key 隔离

### 4.4 Swarm 隔离

- 每任务独立 swarm_id
- agent_execute 必须带 swarm_id 参数
- convener 启动时打印 swarm_id + 项目路径作为任务身份

### 4.5 模式切换日志

`.mode-switches.json` 是项目内的。

---

## 五、Ruflo MCP 不可用的降级

### 5.1 本地 JSON Fallback（v1.5 路径统一为 `~/.jaaos/memory.json`）

Ruflo MCP 挂了（**流程继续不阻塞，不停止**——与 SKILL.md §十一错误处理表统一）：
- Phase 0.5 查记忆 → 读 `~/.jaaos/memory.json`（本地 JSON 文件，无向量搜索，线性扫描）
- Phase 10 存记忆 → 写 `~/.jaaos/memory.json`（追加，带 timestamp）
- convener 提示卷卷「Ruflo MCP 不可用，已降级为本地 JSON 模式 (`~/.jaaos/memory.json`)，向量搜索不可用」
- ⚠️ v1.5：SKILL.md §十一已同步此路径，两处文档口径一致

### 5.2 Agent 间通信降级

MCP 不可用时，所有通信走文件消息（见 message-protocol.md §1.1），不走 MCP 工具。

### 5.3 Leader 失联的二次检测

- convener 心跳由 leader 检测
- **leader 失联由 architect 检测**（architect 每 60s 检查 leader 心跳，90s 无更新判失联）
- architect 失联由 docs-researcher 检测
- 形成心跳链：docs-researcher → architect → leader → convener
