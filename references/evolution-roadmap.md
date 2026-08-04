# Juanjuan Team Evolution Roadmap

**用途**：规划 v1.5 → v2.0 的进化路径，避免无序迭代。

**核心理念**：每次大改必须对齐 roadmap，不做不在路径上的功能。

---

## 一、版本时间线

```
v1.0 (2026-07-xx) ──→ v1.1 ──→ v1.2 ──→ v1.3 ──→ v1.4 (2026-08-04)
                                            │
                                            ↓
                                          v1.5 (本次自检+进化)
                                            │
                                            ↓
                                          v1.6 (下次)
                                            │
                                            ↓
                                          v2.0 (JAAOS 融合)
```

---

## 二、v1.5（本次，已完成）

### 2.1 做了什么

- 修 12 个具体缺陷（D-1 ~ D-12）
- 加元验证层（meta-verification.md + meta-verify.sh，5 项检查）
- 加可观测性（observability.md + run_id + phase-trace + rolling summary）
- 加 10 条反模式清单（anti-patterns.md）
- 加 e2e dry-run 脚本
- 加记忆闭环验证脚本

### 2.2 没做（留给 v1.6）

- swarm-spawn.sh 仍是文档脚本（没真 spawn）
- run_id 仍靠 Agent 自觉写（没 hook 强制）
- memory_store 失败时无自动重试

---

## 三、v1.6（下次迭代）

### 3.1 真 spawn 落地

**目标**：swarm-spawn.sh 不再只 echo，真正调 MCP 工具 spawn 7 人。

**方案**：
- 脚本检测 ruflo MCP 是否可用（`claude mcp list`）
- 可用：调 `mcp__claude-flow__swarm_init` + `agent_spawn × 7`
- 不可用：降级为文档模式，明示「MCP 不可用，spawn 由 convener 在会话内完成」

### 3.2 PreToolUse hook 强制 run_id

**目标**：Agent 写 `.msg/*.json` 必须带 run_id，否则 hook 拦截。

**方案**：
- hook-enforce.sh 加新检查：Write 到 `.msg/*.json` 时，解析 content 验证含 `run_id` 字段
- 无 run_id：BLOCKED，提示「按 observability.md §一规范，消息必须带 run_id」

### 3.3 memory_store 自动重试

**目标**：Phase 10 存记忆失败时不阻塞流程，自动重试 3 次。

**方案**：
- docs-researcher 调 memory_store 失败时，本地重试 3 次（间隔 1s/2s/4s）
- 仍失败：降级写 `~/.jaaos/memory.json`，提示「ruflo memory 不可用，已降级本地 JSON」
- 重试逻辑写在 docs-researcher 的 role prompt 里

### 3.4 Phase 0.5 优先读 .phase-summary.md

**目标**：长任务的 rolling summary 优先于全量 memory 查询。

**方案**：
- docs-researcher 在 Phase 0.5 先读 `.phase-summary.md`（若存在）
- 再调 memory_search 补充跨项目经验
- 两份结果合并给 convener

---

## 四、v2.0（JAAOS 融合）

### 4.1 目标

接入 [[jaaos-architecture-plan]] 的三引擎融合架构：
- Ruflo（本 skill 的执行层）
- Hermes Kanban（任务可视化）
- AgentTeams（跨项目协调）

### 4.2 接入点

| juanjuan-team | JAAOS 对应 |
|---------------|-----------|
| state-machine.md §八 Hermes Kanban 映射（已预留） | Hermes Kanban 列 |
| Phase 10 存记忆 | mem0 经验库（[[agent-self-evolution]]） |
| 7 个 role-*.md | Neo4j 自画像节点（[[agent-self-evolution]]） |
| convener 单点 | AgentTeams 协调器 |

### 4.3 验收标准

- 卷卷可在 Hermes Kanban 看到每个 Phase 的卡片
- AgentTeams 可跨项目查到 juanjuan-team 的经验
- convener 可被 AgentTeams 协调器替代（可选）

---

## 五、长期方向（v2.5+）

### 5.1 Web UI 可视化

- 用 hermes-studio 类似的 Web UI 看 phase-trace.json
- 实时观察对抗式辩论过程
- 历史项目经验聚合分析

### 5.2 跨项目记忆聚合

- 按 tag 聚合多个项目的踩坑
- 自动发现模式（如"每次涉及 React 的项目都遇到 X 问题"）
- 接入 Neo4j 知识图谱

### 5.3 团队配置热加载

- 运行中调整角色（如临时加一个 security-architect）
- 不重跑 Phase，只影响后续

---

## 六、不做清单（YAGNI 永久）

- 不做 TTS / 语音（hermes-studio 做了，但超范围）
- 不做 MCU/ESP32 集成（同上）
- 不做自己的 Web 服务器（用 Claude Code 的 MCP 即可）
- 不做自己的 DB（用 ruflo memory + 本地 JSON 够了）
- 不做 GUI 客户端（Claude Code 本身是 UI）
- 不做完整的 group chat UI（hermes-studio 已经做了，不重复造轮子）

---

## 七、与 hermes-studio 的关系定位

hermes-studio 是**通用 group chat 工作台**，juanjuan-team 是**专注对抗式协作的 skill**。

两者关系：
- 互补：hermes-studio 提供 Web UI 和 runtime，juanjuan-team 提供对抗式协议
- 不竞争：hermes-studio 的 agent 是分工协作，juanjuan-team 的 agent 是互审挑错
- 可融合：未来 juanjuan-team 可作为 hermes-studio 的一个 workflow 模板

---

## 八、进化原则

1. **系统性问题 > 具体缺陷**：修缺陷不修系统 = 下次还会冒出来
2. **可观测 > 自觉**：规则要变成脚本能验证的
3. **闭环 > 单向**：存的记忆要能查出来才算闭环
4. **借鉴 > 自创**：先看 hermes-studio / agent-review-panel / ChatGPT JAIT 有没有现成方案
5. **YAGNI**：不在 roadmap 上的功能不做，避免范围蔓延
6. **反模式驱动**：每次发现的缺陷归纳成反模式，避免重蹈覆辙
