# Juanjuan Team 反模式清单（v1.5）

**用途**：把 v1.4 自检发现的 12 个具体缺陷归纳为 10 条反模式，供未来 v1.6+ 避免重蹈覆辙。

**核心理念**：具体缺陷会重复出现，反模式是根因。

---

## 一、10 条反模式

### AP-1 文档脚本伪装成执行脚本

**症状**：脚本名暗示执行（如 `swarm-spawn.sh`），但内容只 echo 文档。
**根因**：开发时图省事，先写文档脚本，后没改成真执行。
**影响**：使用者误以为脚本跑了，实际没跑。
**修复**：要么真执行，要么顶部明示「仅文档化」+ 真执行走哪里（MCP 工具）。
**v1.5 案例**：D-2，swarm-spawn.sh 顶部加明示。

---

### AP-2 数学不验证

**症状**：文档里的示例数字手算不对。
**根因**：写示例时脑算/估算，没回头验证。
**影响**：读者照抄示例得到错误结果，对 skill 信心下降。
**修复**：每个示例数字必须手算验证一遍，写「v1.5: 已验证数学正确」标注。
**v1.5 案例**：D-11，decision-engine.md 方案 B/C 分数重算。

---

### AP-3 角色归属三处不一致

**症状**：同一角色（如 Optimizer）在 SKILL.md / global-rules.md / decision-engine.md 表述不同。
**根因**：改了 A 文档忘了同步 B/C。
**影响**：Agent 不知道该听哪个，行为漂移。
**修复**：所有角色归属的改动必须 grep 三处文档同步。
**v1.5 案例**：D-12，Optimizer 归属统一为 architect。

---

### AP-4 模式表前后口径不一

**症状**：模式改名后（Normal → Manual），脚本 case 分支没同步。
**根因**：改名只改了文档，没 grep 代码。
**影响**：脚本接收新模式名报错，或接收旧模式名不告警。
**修复**：改名时必须 grep 所有 `*.sh` 和 `*.md`。
**v1.5 案例**：D-1，swarm-spawn.sh case 分支加 `manual)` 并保留 `normal)` 作 deprecated alias。

---

### AP-5 跨平台表推荐不存在的命令

**症状**：跨平台兼容表推荐 `codex review --focus security`，但验证表说该子命令不存在。
**根因**：跨平台表凭印象写，没真实验证。
**影响**：用户照表跑命令报错。
**修复**：跨平台表必须每条都有验证证据，标注「已验证/未验证」。
**v1.5 案例**：D-3/D-4，agent-commands.md §五统一为真实存在的命令。

---

### AP-6 频率控制写死不感知模式

**症状**：备份脚本写死每日 3 次，但 SKILL.md 说 YOLO 模式 6 次。
**根因**：脚本和文档脱节，模式感知没落到脚本。
**影响**：YOLO 模式被限制，违背设计意图。
**修复**：所有模式相关的阈值都必须参数化，脚本接收模式参数。
**v1.5 案例**：D-5，backup-script.sh 加 MODE 参数。

---

### AP-7 错误吞噬

**症状**：`2>/dev/null` 吞掉关键错误。
**根因**：避免日志噪声，结果连关键错误也吞了。
**影响**：secrets 排除失败时静默把 .env 打包进 tar.gz，critical 事故。
**修复**：错误重定向到临时日志文件，失败时 cat 出来；关键操作后做 post-verify（如 tar 后验证不含 .env）。
**v1.5 案例**：D-6，backup-script.sh 不再吞错 + 加 secrets 泄露验证。

---

### AP-8 正则覆盖不全

**症状**：secret 检测正则只覆盖 sk-/ghp_/AKIA，漏 glpat-/xoxb-/eyJ 等。
**根因**：加正则时只想到常见几个，没系统梳理常见 token 格式。
**影响**：GitLab/Slack/JWT 等 token 漏检。
**修复**：维护一个 token 格式清单，每次发现新的就加。
**v1.5 案例**：D-7，hook-enforce.sh 加 glpat-/xoxb-/eyJ 正则。

---

### AP-9 阈值一刀切

**症状**：文件长度检查写死 500 行，但 ECC 项目 rules 允许 800。
**根因**：hook 不知道项目 rules 存在。
**影响**：ECC 项目合法文件被误拦。
**修复**：hook 先检查项目根 `.claude/rules/ecc/`，存在用项目阈值，否则用默认。
**v1.5 案例**：D-8，hook-enforce.sh 加项目 rules 感知。

---

### AP-10 路径/字段重复维护

**症状**：超时阈值在 fault-tolerance.md 和 message-protocol.md 各一份；MCP 降级路径在 SKILL.md 和 fault-tolerance.md 各一份。
**根因**：两处定义方便速查，但容易漂移。
**影响**：两处不一致时使用者不知道信哪个。
**修复**：定义唯一权威源（如 fault-tolerance.md），其他文档明示「以 X 为准，本表仅速查」。
**v1.5 案例**：D-9/D-10，路径统一为 `~/.jaaos/memory.json`，超时以 fault-tolerance.md 为准。

---

## 二、反模式 vs 具体缺陷

反模式是根因，具体缺陷是表象。修一个反模式可能消除多个缺陷：

| 反模式 | 对应缺陷 |
|--------|---------|
| AP-1 | D-2 |
| AP-2 | D-11 |
| AP-3 | D-12 |
| AP-4 | D-1 |
| AP-5 | D-3, D-4 |
| AP-6 | D-5 |
| AP-7 | D-6 |
| AP-8 | D-7 |
| AP-9 | D-8 |
| AP-10 | D-9, D-10 |

12 个缺陷对应 10 条反模式（AP-5/AP-10 各覆盖 2 个）。

---

## 三、如何避免新反模式

### 3.1 改动前的自检清单

每次改 skill 前，问自己：
- [ ] 这次改动是否会让某处文档与另一处不一致？（AP-3/AP-10）
- [ ] 加的示例数字是否手算验证过？（AP-2）
- [ ] 改的阈值是否参数化了，还是又写死？（AP-6）
- [ ] 加的错误处理是否吞噬了关键错误？（AP-7）
- [ ] 加的正则是否覆盖完整？（AP-8）
- [ ] 加的脚本是真的执行还是只 echo？（AP-1）

### 3.2 改动后的验证

- `meta-verify.sh` 跑一遍
- `grep -r "<旧表述>" ~/.claude/skills/juanjuan-team/` 确保没遗漏
- 跑一次 e2e-dry-run.sh 验证不破坏流程

---

## 四、未来可能出现的反模式（预警）

### AP-11 元验证变成形式主义

**风险**：meta-verify.sh 跑过了，但没人看报告。
**预防**：convener 在 Phase 11 汇报时必须引用 meta-verify 的结论，不能"跑过就行"。

### AP-12 run_id 变成空字段

**风险**：Agent 写 run_id 但不维护 trace。
**预防**：observability.md 明示 run_id 必须绑定 artifacts，meta-verify 检查 artifacts 是否真存在。

---

## 五、v1.6 新增反模式（主+sub 双层对抗相关）

### AP-13 sub-agent 变成形式主义

**症状**：主 Agent 派 sub-agent 但不引用 finding，verdict 自己写。
**根因**：sub-agent 调用流于形式，主 Agent 仍按自己意思判。
**影响**：双层对抗失效，跟没派 sub-agent 一样。
**修复**：MV-6 检查 verdict 必须引用 finding_id 并分类（共识/分歧/盲点）。

### AP-14 sub-agent 串行调用

**症状**：主 Agent 一个一个串行调 sub-agent。
**根因**：图省事，不并行调度。
**影响**：浪费时间，且后面的 sub-agent 可能被前面影响。
**修复**：MV-6 检查 sub-call 时间差 ≤ 1 秒（并行）。

### AP-15 主 Agent 只做汇总员

**症状**：主 Agent 不自己审，只汇总 sub-agent 的 finding。
**根因**：偷懒，把审查责任全甩给 sub-agent。
**影响**：主 Agent 失去独立思考，被 sub-agent 误导也无从发现。
**修复**：MV-6 检查 `.msg/<parent>_self_*.json` 必须存在，且时间戳证明是平行产出。

### AP-16 盲点悄悄采纳

**症状**：主 Agent 采纳了 sub-agent 报的、自己漏的 issue，但不明示"我漏了"。
**根因**：怕丢面子，假装自己本来也知道。
**影响**：无法追溯主 Agent 的盲点模式，下次还会漏。
**修复**：MV-6 检查 `blind_spots` 若非空，每条必须有 `acknowledgement` 字段。

### AP-17 锚定效应

**症状**：主 Agent 先看 sub-agent 的 finding 再写自己的，被 sub-agent 误导。
**根因**：主 Agent 想图省事，"看看 sub 怎么说我再写"。
**影响**：主 Agent 失去独立性，等于 1 个判断 + 复读，不是双层对抗。
**修复**：MV-6 时间戳验证，主 Agent self finding 必须 ≤ sub-agent 调用 + 1s（证明是平行发起）。

---

## 六、反模式 vs 具体缺陷（v1.6 更新）

反模式是根因，具体缺陷是表象。v1.5 修了 12 个缺陷归纳为 10 条反模式，v1.6 新增 5 条反模式（AP-13~17）针对主+sub 双层对抗。

| 反模式 | 对应缺陷/机制 |
|--------|------------|
| AP-1 ~ AP-10 | v1.5 的 12 个缺陷（D-1 ~ D-12） |
| AP-13 ~ AP-17 | v1.6 的主+sub 双层对抗失效场景 |

---

## 五、与 customization.md 的关系

customization.md 教用户"怎么改"，anti-patterns.md 教用户"别这么改"。两者配合使用：
- 想加新功能 → 先看 customization.md
- 改完 → 自检是否踩了反模式 → 看 anti-patterns.md
