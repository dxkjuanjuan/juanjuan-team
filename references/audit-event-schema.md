# v1.8 Audit Event Schema

> 每次 spawn Agent 都追加一行事件到 `<项目>/.audit/events.jsonl`。这是审计的核心——事后能查 reviewer 的 prompt 里有没有 reasoning.md 原文片段。

## 一、文件位置

`<项目>/.audit/events.jsonl`

JSONL 格式（每行一个 JSON 对象，不是 JSON 数组）。

## 二、事件类型

### 2.1 agent_spawn（spawn 前）

```json
{
  "event": "agent_spawn",
  "agent": "architect | reviewer | audit-agent",
  "phase": 2,
  "timestamp": "2026-08-05T10:30:00Z",
  "subagent_type": "juanjuan-architect | juanjuan-reviewer | general-purpose",
  "description": "<Agent 工具调用的 description 参数>",
  "allowed_files": [
    ".shared/requirements.md",
    ".architect/public/design.md"
  ],
  "forbidden_files": [
    ".architect/private/reasoning.md"
  ],
  "prompt_hash": "sha256:<64 位 hex>",
  "prompt_full": "<完整 prompt 全文>",
  "run_in_background": false
}
```

### 2.2 agent_complete（spawn 后）

```json
{
  "event": "agent_complete",
  "agent": "architect",
  "phase": 2,
  "timestamp": "2026-08-05T10:35:00Z",
  "outputs": [
    ".architect/public/design.md",
    ".architect/private/reasoning.md"
  ],
  "status": "completed | failed",
  "failure_reason": "<若 failed>"
}
```

### 2.3 agent_retry（重试时）

```json
{
  "event": "agent_retry",
  "agent": "architect",
  "phase": 2,
  "timestamp": "2026-08-05T10:36:00Z",
  "retry_reason": "<重试原因>",
  "retry_count": 1
}
```

### 2.4 design_leak_detected（检测到策略性语言）

```json
{
  "event": "design_leak_detected",
  "phase": 2,
  "timestamp": "2026-08-05T10:36:00Z",
  "file": ".architect/public/design.md",
  "detected_patterns": [
    {
      "pattern": "考虑过",
      "line": 15,
      "context": "一开始考虑过 MongoDB..."
    }
  ],
  "action": "reject_and_revise",
  "retry_count": 1,
  "max_retries": 2
}
```

### 2.5 phase_transition（Phase 切换）

```json
{
  "event": "phase_transition",
  "from_phase": 2,
  "to_phase": 3,
  "timestamp": "2026-08-05T10:37:00Z",
  "trigger": "architect_complete"
}
```

## 三、字段说明

### 3.1 allowed_files / forbidden_files

这两个字段是审计的核心。每次 spawn 时 convener 必须明示：
- allowed_files：这个 Agent 被允许读哪些文件
- forbidden_files：这个 Agent 被禁止读哪些文件

事后审计时，对照 forbidden_files 检查 prompt_full 里有没有这些文件的内容片段。

### 3.2 prompt_full

**完整 prompt 全文**，不是摘要。这个字段可能很长（几百行），但必须完整。审计就靠这个——如果只记摘要，审不出信息泄漏。

### 3.3 prompt_hash

`sha256:$(echo -n "$prompt_full" | shasum -a 256 | cut -d' ' -f1)`

用于快速比对两次 spawn 的 prompt 是否一致。

## 四、审计查询示例

### 4.1 查 reviewer 的 spawn prompt 里有没有 reasoning.md 原文

```bash
# 提取 reviewer 的 spawn prompt_full
REVIEWER_PROMPT=$(jq -r 'select(.event == "agent_spawn" and .agent == "reviewer") | .prompt_full' <项目>/.audit/events.jsonl)

# 提取 reasoning.md 全文
REASONING=$(cat <项目>/.architect/private/reasoning.md)

# 检查 reasoning.md 的原文片段是否出现在 reviewer prompt 里
# 用最长的 50 字符连续片段做匹配（避免短片段误报）
echo "$REASONING" | grep -oE '.{50,}' | while read -r fragment; do
  if echo "$REVIEWER_PROMPT" | grep -qF "$fragment"; then
    echo "LEAK DETECTED: reasoning.md 片段出现在 reviewer prompt 里:"
    echo "片段: $fragment"
  fi
done
```

### 4.2 查实际 spawn 次数

```bash
jq -r 'select(.event == "agent_spawn") | .agent' <项目>/.audit/events.jsonl | sort | uniq -c
```

预期输出（v1.8 MVP）：
```
   1 architect
   1 reviewer
   1 audit-agent（Phase 5）
```

### 4.3 查所有失败事件

```bash
jq -r 'select(.event == "agent_complete" and .status == "failed") | "\(.agent) at \(.timestamp): \(.failure_reason)"' <项目>/.audit/events.jsonl
```

## 五、v1.9 扩展（v1.8 不做）

v1.9 会加：
- `sub_agent_spawn` 事件（主 Agent 派 sub-agent）
- `consensus_reached` 事件（对话模式辩论收敛）
- `blind_review_broken` 事件（盲审被破坏，如 reviewer 偷看了 reasoning.md）
