# Juanjuan Team Sub-Agent Team 规范（v2.0）

**核心设计**：7 主角色都是项目组，每个主角色下可以 spawn 自己的 sub-agent team 帮做细分任务。sub 不是独立主角色，不能顶替主角色做 verdict。

---

## 一、项目组结构

```
7 主角色（项目组）
├── convener（项目组）
│   └── 3 sub: 漏 issue / 主观判断 / 越权检查
├── architect（项目组）
│   └── 3 sub: 论据充分性 / 备选遗漏 / 任务拆解粒度
├── reviewer（项目组）
│   └── 4 sub: typescript-reviewer / security-reviewer / silent-failure-hunter / type-design-analyzer
├── coder（项目组）
│   └── 3 sub: tdd-guide / build-error-resolver / silent-failure-hunter
├── frontend（项目组）
│   └── 2 sub: react-reviewer / a11y-architect
├── docs-researcher（项目组）
│   └── 2 sub: docs-lookup / general-purpose
└── leader（不派 sub，v1.7 已删）

总: 17 sub + 7 主 = 24 路
```

---

## 二、关键约束（卷卷强调的）

1. **Sub agent 不能是独立主角色**——sub 不能顶替 reviewer 做 verdict
2. **Sub agent 帮主角色做细分任务**——主角色汇总 sub 的 finding 后做 verdict
3. **Sub 只产 issue list / 建议**，不写最终产出
4. **最终 verdict 永远由主角色定**
5. **Sub 失败时主角色接管**，不甩锅

---

## 三、Sub 调用方式

### 3.1 Lite/Medium 任务（Agent Teams teammate 路径）

主角色在 prompt 里写："调 Agent 工具 spawn 一个 typescript-reviewer sub 帮审 TS 类型"，Claude 读到后自己调：

```
Agent({
  subagent_type: "typescript-reviewer",  // ECC 内置的 sub
  description: "审 src/auth/login.ts 类型安全",
  prompt: "...",
  run_in_background: true
})
```

### 3.2 Complex 任务（`claude -p` 真进程路径）

主角色自己也是 `claude -p` 真进程，它在自己进程内调 Agent 工具 spawn sub（sub 是主角色进程的子上下文，不是独立 OS 进程）。

**注意**：v2.0 的 sub 不是真独立进程，是主角色进程内的子上下文。这是合理的——sub 帮主角色做细分任务，不需要进程级隔离。

---

## 四、Sub 数量配置

| 模式 | reviewer sub | 其他主角色 sub | 总 sub |
|------|------------|-------------|------|
| Safe | 4 | 各 2-3 | 17 |
| Manual | 4 | 各 2-3 | 17 |
| Auto | 2 | 各 1-2 | 9 |
| YOLO | 2 | 各 1 | 7 |
| Lite | 仅 reviewer 1 | 0 | 1 |

---

## 五、Sub 调用证据

每次 sub 调用产生记录到 `.audit/sub-calls/`：

```
<项目目录>/.audit/sub-calls/<parent>_<subagent_type>_<phase>_<ts>.json
```

格式：
```json
{
  "sub_call_id": "<uuid>",
  "parent_agent": "reviewer",
  "subagent_type": "typescript-reviewer",
  "task": "审 src/auth/login.ts 类型安全",
  "findings": [...],
  "started_at": "<ISO 8601>",
  "ended_at": "<ISO 8601>",
  "status": "completed | failed",
  "fallback": "主角色接管 | null"
}
```

---

## 六、Sub 失败处理

```
sub 调用失败
  ↓
主角色重试 1 次（换更明确任务描述）
  ↓ 仍失败
主角色自己接管该子任务（不算甩锅，算降级）
  ↓
在 sub-call 记录标 status: "failed", fallback: "主角色接管"
  ↓
继续流程，不阻塞
```

---

## 七、反模式（v1.7 已加）

- AP-13 sub 变成形式主义（派但不引用 finding）
- AP-14 sub 串行调用（应该并行）
- AP-15 主角色只做汇总员（不自己审）
- AP-16 盲点悄悄采纳（不披露）
- AP-17 锚定效应（先看 sub 才写自己）
- AP-18 sub 无限生长（sub 不能再 spawn 子 sub）
- AP-19 leader sub 形同虚设（v1.7 已删 leader sub）

---

## 八、v2.0 不做（YAGNI）

- 不做 sub 之间的通信（sub 之间不互相对话，只跟主角色汇报）
- 不做 sub 的 sub（sub 是终端节点，不能再派）
- 不做 sub 跨会话存活（sub 跑完就退出）
