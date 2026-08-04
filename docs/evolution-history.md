# Juanjuan Team 演进史（v1.0 -> v2.2）

> 从"剧本版"到"真 7-Agent 系统"的完整演进记录。每个版本都有真实验证任务 + commit + 产出。

---

## 一、版本总览

| 版本 | 日期 | 核心改进 | 真进程数 | 验证任务 |
|------|------|---------|---------|---------|
| v1.0~v1.4 | 2026-07 ~ 2026-08-04 | 剧本版（1 Claude 演 7 角色） | 0 | 无真 spawn |
| v1.5 | 2026-08-04 | 修 12 缺陷 + 元验证层 + 可观测性 | 0 | 无真 spawn |
| v1.6 | 2026-08-04 | 主+sub 双层对抗 + 文档完善 | 0 | 无真 spawn |
| v1.7 | 2026-08-04 | 自审 + 复杂度感知 + tool_call_id | 0 | 无真 spawn |
| v1.8 | 2026-08-05 | Agent Teams 真 spawn 3 Agent | 2 teammate | TODO list |
| v1.9 | 2026-08-05 | claude -p 真进程 spawn | 2 真进程 | 百万用户登录系统 |
| v2.0 | 2026-08-05 | 完整 7-Agent + 11 Phase + 跨平台抽象 + 模型分层 | 2 真进程 | 博客系统 |
| v2.1 | 2026-08-05 | 真 7-Agent 完整 11 Phase + 真并行 | 6 真进程 | URL 短链接系统 |
| v2.2 | 2026-08-05 | Phase 8/9/10 真做 + sub-agent 派发 + 防断联 + 项目命名 | 9 真进程累计 | URL 短链接系统延续 |

---

## 二、关键转折点

### 2.1 v1.7 -> v1.8: 从"剧本"到"系统"

**问题**: v1.0~v1.7 全是 Claude 一个人演 7 个角色，没有真 spawn 过独立 Agent。所有"对抗式协作"都是演的。

**v1.8 突破**: 启用 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`，用 Agent 工具召唤真 teammate。第一次让 architect 和 reviewer 由两个独立 Claude 实例完成盲审。

**证据**:
- architect agent_id: `architect@session-9e9c73b9`（name@session 格式，是 teammate）
- reviewer agent_id: `reviewer@session-9e9c73b9`
- 两者通过 mailbox 通信（不是一次性返回）
- architect 完成后发 idle_notification（持续运行）

### 2.2 v1.8 -> v1.9: 从"同进程"到"真进程"

**问题**: Agent Teams teammate 还是同进程子上下文，PPID 是主 Claude Code，不是真独立 OS 进程。

**v1.9 突破**: 用 `claude -p` CLI 启动真独立 OS 进程，PPID=1（init 启动）。

**证据**:
- architect PID 39250 PPID 1
- reviewer PID 44389 PPID 1
- reviewer 有独立 cost 统计 $2.02（teammate 不会有）
- `ps -ef` 看到独立 `claude -p` 进程

### 2.3 v1.9 -> v2.0: 从"2 Agent"到"完整流程"

**问题**: v1.9 只跑 architect + reviewer 2 个真进程，没跑完整 11 Phase。

**v2.0 突破**: 加完整 11 Phase 流程 + 跨平台抽象层 + 模型分层 + sub-agent team 规范。

### 2.4 v2.0 -> v2.1: 从"2 真进程"到"6 真进程"

**问题**: v2.0 只跑了 architect + reviewer 2 个真进程，其他角色由主会话扮演。

**v2.1 突破**: 6 个真 claude -p 进程跑完整 11 Phase：
- architect PID 95116 PPID 1（270s）
- reviewer PID 97243 PPID 1（180s）
- leader PID 98721 PPID 1（101s）
- docs-researcher PID 99886 PPID 1（120s）
- coder PID 1256 PPID 1（140s 并行）
- frontend PID 1273 PPID 1（140s 并行）

**真并行**: coder + frontend 同时 spawn 同时完成（v2.0 没做到）。

### 2.5 v2.1 -> v2.2: 补完 Phase 8/9/10 + sub-agent

**问题**: v2.1 的 Phase 8/9/10 没真做，sub-agent team 没真派发。

**v2.2 突破**:
- Phase 8 真代码审查（reviewer PID 4242 PPID 1，160s，13 issues）
- Phase 9 真备份（tar.gz 34K + git bundle）
- Phase 10 真存记忆（docs-researcher PID 5919 PPID 1，61s，存 ruflo memory）
- sub-agent team 真派发（reviewer PID 7008 PPID 1，派 typescript-reviewer + security-reviewer，31 sub findings）

---

## 三、真进程证据汇总

### 3.1 v1.9 真 process（2 个）

| Agent | PID | PPID | 任务 | 耗时 | cost |
|-------|-----|------|------|------|------|
| architect | 39250 | 1 | 百万用户登录系统 | 210s | - |
| reviewer | 44389 | 1 | 盲审 design.md | 210s | $2.02 |

### 3.2 v2.0 真 process（2 个）

| Agent | PID | PPID | 任务 | 耗时 |
|-------|-----|------|------|------|
| architect | 73894 | 1 | 博客系统 | 300s |
| reviewer | 77914 | 1 | 盲审 design.md | 90s |

### 3.3 v2.1 真 process（6 个）

| Agent | PID | PPID | 任务 | 耗时 |
|-------|-----|------|------|------|
| architect | 95116 | 1 | URL 短链接系统 | 270s |
| reviewer | 97243 | 1 | 盲审 design.md | 180s |
| leader | 98721 | 1 | 裁决 | 101s |
| docs-researcher | 99886 | 1 | 写 spec | 120s |
| coder | 1256 | 1 | 写 stub.ts | 140s 并行 |
| frontend | 1273 | 1 | 写 stub.tsx | 140s 并行 |

### 3.4 v2.2 新增真 process（3 个）

| Agent | PID | PPID | 任务 | 耗时 |
|-------|-----|------|------|------|
| reviewer (Phase 8) | 4242 | 1 | 代码审查 | 160s |
| docs-researcher (Phase 10) | 5919 | 1 | 存记忆 | 61s |
| reviewer (sub-agent 派发) | 7008 | 1 | 派 2 sub | 211s |

### 3.5 累计真 process 数

- v1.9: 2
- v2.0: 2
- v2.1: 6
- v2.2: 3 新增 + 6 延续 = 9 累计跑过 URL 短链接项目

**全部 PPID=1**（init 启动的真独立 OS 进程），不是 Sub Agent。

---

## 四、对抗式协作证据

### 4.1 reviewer 挑出的 critical issues（architect 漏的）

| 版本 | 任务 | critical issues |
|------|------|----------------|
| v1.8 | TODO list | 3 critical（archived 死胡同 / UNIQUE 冲突 / 硬删除矛盾） |
| v1.9 | 百万用户登录 | 2 critical（access token 撤销 / SHA-256 反模式） |
| v2.0 | 博客系统 | 2 critical（文章 XSS / 评论 XSS） |
| v2.1 | URL 短链接 | 2 critical（跨用户权限错乱 / SSRF） |

**对抗价值**: 每个 critical 都是 architect 自己没发现的真问题，单 Agent 自我审发现不了。

### 4.2 盲审隔离证据

每次都验证 reviewer 没读 reasoning.md：
- v1.8: 0 泄漏
- v1.9: 0 泄漏
- v2.0: 0 泄漏
- v2.1: 0 泄漏（jq 精确检查 Read 调用）

---

## 五、文件结构演进

### v1.0~v1.7
```
~/.claude/skills/juanjuan-team/
├── SKILL.md
├── references/
│   ├── global-rules.md
│   ├── role-*.md (7 个角色)
│   └── ...
└── scripts/
```

### v1.8（加 agent 定义文件）
```
~/.claude/agents/
├── juanjuan-convener.md
├── juanjuan-architect.md
└── juanjuan-reviewer.md

~/.claude/skills/juanjuan-team/
└── references/audit-event-schema.md (新)
```

### v1.9（加 claude -p 真进程脚本）
```
~/.claude/skills/juanjuan-team/scripts/
├── global-spawn.sh (新)
├── team-status.sh (新)
├── mailbox.sh (新)
├── task-classify.sh (新)
├── phase-state.sh (新)
├── cleanup-stale.sh (新)
└── registry.sh (新)
```

### v2.0（加 4 个角色 + 4 个 references）
```
~/.claude/agents/
├── juanjuan-leader.md (新)
├── juanjuan-coder.md (新)
├── juanjuan-frontend.md (新)
└── juanjuan-docs-researcher.md (新)

~/.claude/skills/juanjuan-team/references/
├── sub-agent-team.md (新)
├── v2.0-11-phase-flow.md (新)
├── v2.0-cross-platform-abstraction.md (新)
└── v2.0-model-layering.md (新)
```

### v2.2（加防断联 + 项目命名）
```
~/.claude/skills/juanjuan-team/scripts/
├── resume.sh (新)
├── auto-spawn.sh (新)
└── continue.sh (新)

~/.claude/skills/juanjuan-team/references/
├── v2.2-resilience.md (新)
└── v2.2-project-naming.md (新)
```

---

## 六、commit 历史

```
v2.2: Phase 8/9/10 真做 + sub-agent team 真派发
v2.1: 真 7-Agent + 完整 11 Phase - URL 短链接系统
v2.0: 完整 7-Agent + 11 Phase + 跨平台抽象 + 模型分层
v1.9: 分层调度架构 - claude -p 真进程 spawn + 6 个新脚本
v1.8: 真 spawn 落地 - 3 个独立 Agent + audit-event schema
v1.7: 自审查 + 修 12 缺陷 + 复杂度感知配置
v1.6: 自进化 - 主+sub 双层对抗 + 文档完善
v1.5: 自检+进化 - 修 12 缺陷 + 加元验证层 + 可观测性
v1.4.2: GitHub 调研优化 - domain-checklists + HTML 报告可选
```

---

## 七、v2.3+ 待做

按卷卷说的"五、六到时候再说"：

5. **Codex/Gemini 后端实现**: 跨平台抽象层落地，让 juanjuan-team 能用 Codex / Gemini CLI 跑
6. **跨项目记忆聚合**: 把多个项目记忆连成知识图谱（Neo4j，研究性工作）

**v2.3 优先级**：
1. Codex CLI 后端实现
2. Gemini CLI 后端实现
3. 跨项目记忆聚合（v2.4+ 再做）
