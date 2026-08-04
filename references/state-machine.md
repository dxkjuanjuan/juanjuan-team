# Juanjuan Team 任务状态机

**用途**：每个任务的生命周期管理。
**来源**：借鉴 ChatGPT JAIT v1.0 Part 6 Module 2，对齐 11 Phase 流程。

---

## 一、状态定义

每个任务存在以下状态之一：

```
CREATED
  ↓
UNDERSTANDING
  ↓
PLANNING
  ↓
RESEARCHING
  ↓
DESIGNING
  ↓
IMPLEMENTING
  ↓
REVIEWING
  ↓
TESTING
  ↓
DELIVERING
  ↓
COMPLETED
```

---

## 二、状态与 11 Phase 映射

| 状态 | 对应 Phase | 负责人 | 说明 |
|------|-----------|--------|------|
| CREATED | 触发 juanjuan-team skill | convener | 任务被创建，等待接收 |
| UNDERSTANDING | Phase 0 头脑风暴 | convener + leader | 提取需求，澄清意图 |
| PLANNING | Phase 1 模式选择 + Phase 2 建目录 | convener + leader | 选模式、建项目目录 |
| RESEARCHING | Phase 0 内嵌（docs-researcher） | docs-researcher | 查记忆库、查外部资料 |
| DESIGNING | Phase 3 方案 + Phase 4 审核 | architect + reviewer + convener | 出方案、三方审核、定稿 |
| IMPLEMENTING | Phase 7 实施 | frontend + coder | 写代码 |
| REVIEWING | Phase 8 代码审查 | reviewer | 独立审查代码 |
| TESTING | Phase 8 内嵌 | frontend + coder | 跑测试，确保 80% 覆盖率 |
| DELIVERING | Phase 9 备份 + Phase 10 存记忆 + Phase 11 汇报 | convener + docs-researcher | 备份、存档、汇报 |
| COMPLETED | 项目归档 | convener | 任务完成，记忆已存 |

---

## 三、状态转移规则

### 3.1 必须遵守的顺序

复杂任务**不可跳过**：
- PLANNING（必须有方案才能实施）
- REVIEWING（必须有审查才能交付）
- TESTING（必须有测试才能交付）

### 3.2 允许的回退

| 回退路径 | 触发条件 | 负责人 |
|---------|---------|--------|
| REVIEWING → DESIGNING | reviewer 发现架构问题 | leader 裁决 |
| TESTING → IMPLEMENTING | 测试失败，需修复 | coder/frontend |
| DELIVERING → REVIEWING | 卷卷审核时发现问题 | convener |
| 任意 → CREATED | 重大方向调整，重新开始 | 卷卷决定 |

### 3.3 禁止的跳跃

- 不允许 CREATED → IMPLEMENTING（跳过理解和设计）
- 不允许 IMPLEMENTING → COMPLETED（跳过审查和测试）
- 不允许 REVIEWING → COMPLETED（跳过测试）

---

## 四、状态机图

```
                    ┌─────────────┐
                    │   CREATED   │
                    └──────┬──────┘
                           ↓
                  ┌─────────────────┐
                  │  UNDERSTANDING  │ ←─────┐
                  └────────┬────────┘       │
                           ↓                │ 回退
                  ┌─────────────────┐       │ （重大调整）
                  │    PLANNING     │ ──────┘
                  └────────┬────────┘
                           ↓
                  ┌─────────────────┐
                  │   RESEARCHING   │
                  └────────┬────────┘
                           ↓
                  ┌─────────────────┐
                  │    DESIGNING    │ ←─────┐
                  └────────┬────────┘       │ 回退
                           ↓                │ （架构问题）
                  ┌─────────────────┐       │
                  │  IMPLEMENTING   │ ──────┘
                  └────────┬────────┘
                           ↓
                  ┌─────────────────┐
                  │    REVIEWING    │ ──────┐
                  └────────┬────────┘       │ 回退
                           ↓                │ （测试失败）
                  ┌─────────────────┐       │
                  │     TESTING     │ ──────┘
                  └────────┬────────┘
                           ↓
                  ┌─────────────────┐
                  │   DELIVERING    │ ←─────┐
                  └────────┬────────┘       │ 回退
                           ↓                │ （卷卷发现问题）
                  ┌─────────────────┐       │
                  │    COMPLETED    │ ──────┘
                  └─────────────────┘
```

---

## 五、状态转移触发条件

| 当前状态 | 触发条件 | 目标状态 | 触发者 |
|---------|---------|---------|--------|
| CREATED | 收到 juanjuan-team skill 触发 | UNDERSTANDING | convener |
| UNDERSTANDING | 需求清晰，卷卷确认 | PLANNING | convener |
| PLANNING | 模式选定，目录建好 | RESEARCHING | leader |
| RESEARCHING | docs-researcher 完成资料查询 | DESIGNING | leader |
| DESIGNING | 方案审核通过，卷卷确认 | IMPLEMENTING | convener |
| IMPLEMENTING | frontend + coder 完成代码 | REVIEWING | leader |
| REVIEWING | reviewer 通过 | TESTING | leader |
| TESTING | 测试覆盖率 ≥ 80% 通过 | DELIVERING | leader |
| DELIVERING | 备份完成 + 记忆已存 | COMPLETED | convener |
| COMPLETED | 任务归档 | （终态） | convener |

---

## 六、异常状态处理

### 6.1 阻塞（BLOCKED）

任务在某个状态卡住超过预期时间：
- convener 上报 leader
- leader 决定：继续等 / 重新规划 / 转 卷卷

### 6.2 失败（FAILED）

某个 Phase 反复失败：
- 记录失败原因到 events 表
- 自动回退到上一个状态
- 累计 3 次失败 → 转 卷卷定夺

### 6.3 取消（CANCELLED）

卷卷主动取消：
- 当前状态标记为 CANCELLED
- 已产生的部分产出仍备份
- 不进入 COMPLETED 状态

---

## 七、状态查询

任何 Agent 可通过 convener 查询当前任务状态：

```json
{
  "task_id": "<任务 ID>",
  "current_state": "<状态名>",
  "current_phase": "<Phase 编号>",
  "responsible_agent": "<当前负责 Agent>",
  "history": [
    {"from": "CREATED", "to": "UNDERSTANDING", "at": "<时间>", "by": "convener"},
    {"from": "UNDERSTANDING", "to": "PLANNING", "at": "<时间>", "by": "convener"}
  ],
  "blocked": false,
  "failure_count": 0
}
```

---

## 八、与 Hermes Kanban 的对接（未来）

未来 JAAOS 项目落地后，本状态机的每个状态对应 Hermes Kanban 的一张卡片列：

| 本状态机 | Hermes Kanban 列 |
|---------|-----------------|
| CREATED | backlog |
| UNDERSTANDING / PLANNING / RESEARCHING / DESIGNING | planning |
| IMPLEMENTING / REVIEWING / TESTING | running |
| DELIVERING | review |
| COMPLETED | done |

本次 juanjuan-team skill 不强制接入 Kanban，状态在 convener 内部维护即可。
