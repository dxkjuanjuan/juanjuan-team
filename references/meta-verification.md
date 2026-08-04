# Juanjuan Team 元验证规范

**用途**：定义"如何验证 skill 在正确运行"的 5 个检查项。把"对抗式协作"从 Agent 自觉变成可观测、可验证的工程化机制。

**核心理念**：规则写了不等于被遵守——必须有脚本能验证。

---

## 一、5 个检查项

### MV-1 独立审核证据

**验证目标**：Phase 4/6/8 三方审核时，architect / reviewer / docs-researcher 真的独立产出意见，没有"看了别人意见才写"。

**验证方式**：
- 检查 `<项目>/.msg/` 目录
- 每个 Phase 的三方审核，必须存在 3 个独立 ack 文件：
  - `architect_convener_Phase<N>_<ts>.ack.json`
  - `reviewer_convener_Phase<N>_<ts>.ack.json`
  - `docs-researcher_convener_Phase<N>_<ts>.ack.json`
- ack 时间戳必须早于 convener 的汇总消息时间戳（证明没等汇总才 ack）

**失败动作**：报警"Phase N 独立审核证据缺失"，标记此 Phase 失败，提示卷卷人工核查。

---

### MV-2 并行调用证据

**验证目标**：convener 真的并行（不是串行）调用三方审核。

**验证方式**：
- 检查 convener 发起三方的 request 文件时间戳
- 三个文件创建时间差必须 < 1 秒（同一秒内并行发起）
- 文件：
  - `convener_architect_Phase<N>_<ts>.json`
  - `convener_reviewer_Phase<N>_<ts>.json`
  - `convener_docs-researcher_Phase<N>_<ts>.json`

**失败动作**：报警"Phase N 并行调用证据缺失（时间差 > 1s）"，提示可能串行调用。

---

### MV-3 模式切换日志

**验证目标**：模式切换真的是 Phase 边界原子化，不是 Phase 内切。

**验证方式**：
- 若存在 `<项目>/.mode-switches.json`，每条必须含 7 字段：
  - `from`, `to`, `at`, `phase`, `reason`, `transaction_id`, `status`
- `status` 必须是 `committed`（Phase 边界切）或 `saga-rollback`（Phase 内强制切，走 saga）
- 不允许 `status: "partial"`（半截切换，违反原子性）

**失败动作**：报警"模式切换日志异常"，提示 atomicity 破坏。

---

### MV-4 记忆闭环

**验证目标**：Phase 10 存的 memory，Phase 0.5 真的能查出来。

**验证方式**：
- 跑 `scripts/memory-roundtrip-test.sh`
- 流程：存一条测试 memory（key=test-roundtrip-<ts>）→ 立即用相同关键词查 → 验证能查到
- 若 ruflo MCP 不可用，验证 `~/.jaaos/memory.json` 读写正常

**失败动作**：报警"记忆闭环失效"，提示降级为本地 JSON 模式。

---

### MV-5 备份触发

**验证目标**：Phase 8 reviewer verdict=pass 事件真的触发了备份。

**验证方式**：
- 检查 `<项目>/.backups/` 目录
- 若存在 reviewer pass 事件的消息文件，必须存在对应时间戳的 tar.gz + bundle
- 备份文件命名：`YYYY-MM-DD-HHmm-<任务简述>.tar.gz`

**失败动作**：报警"备份触发失效"，提示 convener 检查 reviewer pass 事件订阅。

---

## 二、执行器：scripts/meta-verify.sh

```bash
./scripts/meta-verify.sh <项目目录>
```

输出 JSON 报告：

```json
{
  "project_dir": "<路径>",
  "timestamp": "<ISO 8601>",
  "checks": [
    {"id": "MV-1", "name": "独立审核证据", "status": "pass|fail|skip", "evidence": "..."},
    {"id": "MV-2", "name": "并行调用证据", "status": "pass|fail|skip", "evidence": "..."},
    {"id": "MV-3", "name": "模式切换日志", "status": "pass|fail|skip", "evidence": "..."},
    {"id": "MV-4", "name": "记忆闭环", "status": "pass|fail|skip", "evidence": "..."},
    {"id": "MV-5", "name": "备份触发", "status": "pass|fail|skip", "evidence": "..."}
  ],
  "overall": "pass|fail",
  "failures": ["<失败项列表>"]
}
```

---

## 三、何时跑元验证

### 3.1 自动触发

- Phase 11 汇报时，convener 可选跑一次给卷卷看"对抗真发生了"的证据
- 卷卷显式说「跑元验证」/「验证一下」

### 3.2 手动触发

- 每次大改 skill 后（v1.x → v1.(x+1)）
- 每月一次定期自检
- 怀疑对抗式协作失效时

---

## 四、失败处理

任何一项失败：
1. 不阻塞当前任务流程
2. convener 提示卷卷"元验证 MV-N 失败：<evidence>"
3. 卷卷决定：继续 / 修复 / 回滚
4. 失败记录存 `<项目>/.meta-verify-failures.json` 供回溯

---

## 五、与 hermes-studio 的对比

hermes-studio 用 `run_id` 把同一回复的所有 assistant parts + tool rows 绑在一起，可观测性强。juanjuan-team 借鉴此思路，用 `run_id` 绑定 Phase 的所有消息（见 `observability.md`），元验证基于 run_id 做检查。

差异：
- hermes-studio 的 run_id 在群聊层，每个 agent reply 一个
- juanjuan-team 的 run_id 在 Phase 层，每个 Phase 一个

---

## 六、反模式

### 6.1 不要把元验证当成"额外检查"

元验证是 skill 自检的核心机制，不是可选功能。每次大改 skill 必须跑。

### 6.2 不要让 Agent 自己跑元验证

meta-verify.sh 由 convener 在 Phase 11 触发，或卷卷手动跑。不让其他 Agent 跑（避免自我背书）。

### 6.3 不要静默失败

任何 MV-N 失败必须提示卷卷，不能"算了，下次再说"。
