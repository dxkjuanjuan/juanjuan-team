---
name: juanjuan-team
description: 多 Agent 对抗式协作工作流（juanjuan team）。当用户描述任务（含「做」「修」「写」「实现」「帮我」等动词 + 任务对象 + 复杂度信号）时自动触发，或显式说「juanjuan skill」「用卷卷 skill」「team up」「multi-agent」。先调 superpowers:brainstorming 头脑风暴澄清需求，再选模式（Safe/Manual/Auto/YOLO），然后建项目目录、跑 7 人 Agent 团队（leader/convener/architect/frontend/coder/reviewer/docs-researcher）、智能备份、存档记忆。核心价值是对抗式协作——多个 Agent 同步独立审核同一产出，互相挑错，避免单 Agent 认知连续性错误。**7 Agent 只是默认配置，可改 prompt/数量/理论框架，见 references/customization.md。单文件任务可走 Lite 模式（6 Phase），见 references/lite-mode.md**。
---

# Juanjuan Team Skill

## 一、触发方式

### 1.1 自动触发（推荐）

卷卷描述任务时自动触发，**三要素同时满足**：
1. **动词**：做 / 修 / 写 / 实现 / 帮我 / 搞 / 弄 / 完成 / 改
2. **+ 任务对象**：项目 / bug / 功能 / 页面 / 模块 / 脚本 / 文档
3. **+ 复杂度信号**：多文件 / 跨模块 / 架构影响 / 新功能 / 不确定（单文件单行修改不算）

例：
- "帮我修 React 项目缺失页面" → 自动触发（多文件）
- "做一个 AI 论文管理系统" → 自动触发（新功能）
- "写一个爬虫脚本" → 自动触发（新功能）
- "把 foo 改成 bar" → **不触发**（单行无复杂度）

### 1.2 显式触发

听到以下关键词时也触发：
- `juanjuan skill`（拼音带声调或兜底）
- `用卷卷 skill`
- `用自己的 skills`
- `用 juanjuan team`
- `上 ruflo team`
- `team up`（通用）
- `multi-agent`（通用）

### 1.3 不触发的场景

- 纯问答（"什么是 React"）→ 不触发
- 单文件单行修改（"把 foo 改成 bar"）→ 不触发
- 卷卷明确说"不用 juanjuan team"→ 不触发

## 二、团队配置（7 人，可改）

| # | Agent | 角色 | 跟卷卷对话 |
|---|-------|------|-----------|
| 1 | leader | 调控者 | 间接（通过 convener） |
| 2 | convener | 主对接 + 总审核 | **是**（唯一） |
| 3 | architect | 架构师（类 PM） | 否 |
| 4 | frontend | 前端工程师 | 否 |
| 5 | coder | 后端工程师 | 否 |
| 6 | reviewer | 安全审查 | 否 |
| 7 | docs-researcher | 文稿 + 浏览器调试 | 否 |

**角色详细 prompt 见 `references/role-*.md`，所有角色共享 `references/global-rules.md`。**

## 三、4 种工作模式

| 模式 | 行为 | 何时用 |
|------|------|--------|
| **Safe** | 默认全选最谨慎方案；每阶段都审核 + 卷卷确认 | 重要项目、不确定时 |
| **Manual**（原 Normal） | 团队只做头脑风暴式辅助，**完全由卷卷审核**，reviewer 否决权降级为建议 | 卷卷完全掌控时（原 Normal 改名，避免「Normal=团队正常审」的语义歧义） |
| **Auto** | 团队帮卷卷审核，遇到难抉择的转卷卷定夺 | 日常推荐 |
| **YOLO** | 全权限放给团队，hive-mind 投票决策，投票即审核，最后给卷卷结果 | 信任团队、要快速出结果 |

> ⚠️ Normal 已改名 Manual（卷卷全审），避免命名歧义。原 Normal 触发词仍兼容。

**模式选择时机（关键）**：必须在头脑风暴完成之后。流程顺序严格按 Phase 0 → Phase 1，不可颠倒。

## 四、完整工作流（11 个 Phase + Phase 0.5）

```
[Phase 0: 头脑风暴]  ← Convener 调 superpowers:brainstorming skill
  Convener 调 Skill({ skill: "superpowers:brainstorming" })
  按 SuperPower 流程：探索项目上下文 → 逐个澄清问题
  卷卷确认需求清晰后，进入 Phase 0.5
  ⚠️ 不在 Phase 0 出方案！只澄清需求
  ⚠️ brainstorming 完成后必须回到 juanjuan-team 流程进入 Phase 0.5/1
     （用 AskUserQuestion 选模式），不要继续走 brainstorming 的 design doc 流程
  ↓
[Phase 0.5: 资料查询]  ← docs-researcher 主导，预取式并行（不是真并行）
  docs-researcher 调 memory_search（threshold=0.3, limit=5）+ kimi-webbridge
  结果暂存 <项目>/.phase0.5-findings.json
  Phase 0 brainstorming 完成后，convener 读暂存结果作为 Phase 1 输入
  ⚠️ 预取式并行：Phase 0 开始时 docs-researcher 同步启动（只查不消费），结果暂存；Phase 0 完成后汇合
  ⚠️ DAG 标注：async prefetch, barrier at Phase 1 entry
  ↓
[Phase 1: 模式选择]  ← 必须在出方案之前！用 AskUserQuestion 卡片式选择
  Convener 基于 Phase 0.5 docs-researcher 的查询结果给建议
  用 AskUserQuestion 工具弹卡片：
    - Safe / Manual / Auto / YOLO
    - 每个选项带 description + preview
  卷卷点选 → 进入对应模式
  ⚠️ 为什么先选模式：模式决定「谁来出方案 + 谁来审方案 + 卷卷是否要看」
     - Safe: 卷卷审每个方案
     - Manual: 卷卷完全审（reviewer 否决权降级为建议）
     - Auto: 团队审，难抉择转卷卷
     - YOLO: 团队投票即审核，放宽阈值
  ↓
[Phase 2: 建项目目录]
  ~/项目/YYYY-MM-DD-HHmm-<任务简述>/
  git init
  ↓
[Phase 3: 方案生成]  ← 按模式出方案
  Convener + Architect 出方案 A/B/C
  ⚠️ 不管什么模式，方案必须让卷卷看到（Safe/Manual 详细看，Auto/YOLO 看摘要）
  ⚠️ 卷卷可随时打断，决定是否修改方案
  ↓
[Phase 4: 方案审核]（按模式，对抗式辩论协议）
  Safe/Manual: Architect + Reviewer + Docs-Researcher 三方独立审（卷卷可看每方意见）
  Auto: 同上 + Leader 自检介入（卷卷看汇总摘要）
  YOLO: 全权交团队投票（投票即审核，放宽阈值；卷卷看最终胜出方案）
  Convener 用加权评分公式汇总（详见 references/decision-engine.md）
  ⚠️ 加权评分先跑 LEVEL，再触发辩论（LEVEL C/D 才辩论，详见 global-rules §3.4）
  ⚠️ Convener 不做 Optimizer，Optimizer 由 architect 担任（详见 global-rules §3.5）
  ⚠️ 不管什么模式，最终选定的方案必须让卷卷看到，可打断修改
  ⚠️ Phase 4→3 回退时不重走 Phase 0/1，仅 architect 修订方案；若方案问题源于需求歧义则强制回退到 Phase 0
  ↓
[Phase 5: 设计文档]
  Docs-Researcher 写 spec
  Convener 可调 superpowers:writing-plans 辅助
  ↓
[Phase 6: 文档审核]（按模式）
  Safe/Auto/YOLO: Reviewer 单向审 docs-researcher 的文档（不是互审，docs-researcher 不审自己写的）
  Manual: 跳过，卷卷直接审
  ⚠️ Phase 6 改为 Reviewer 单向审（之前写「互审」有歧义）
  ↓
[Phase 7: 实施]
  Frontend + Coder 并行
  Coder 调 superpowers:test-driven-development 做 TDD
  出 build 错误调 /build-fix 或 build-error-resolver 子 Agent
  ⚠️ frontend + coder 依赖 architect 的接口契约，契约先定义才能并行
  ↓
[Phase 8: 代码审查]
  Reviewer 主动调 /review + /security-review（或 spawn code-reviewer subagent 作为 fallback）
  + 开语言专项子 Agent（typescript-reviewer / python-reviewer 等）并行
  Reviewer 自己做最终 verdict（不甩给子 Agent；子 Agent 只产 issue list，reviewer 合成 verdict 文本）
  ↓
[Phase 9: 智能备份]  ← 事件驱动，不在 Phase 9 单次执行
  tar.gz + git bundle
  命名: YYYY-MM-DD-HHmm-<任务简述>.tar.gz
  位置: 项目目录内 .backups/
  每日上限 3 次（YOLO 模式 6 次）
  详见 references/backup-script.sh
  ⚠️ 备份改为事件驱动：Reviewer verdict=pass 事件触发（不在 Phase 9 单次执行）
  ⚠️ Phase 9 位置改为「最终归档备份」（项目完成时的一次性完整备份）
  ⚠️ 计数器存 <项目>/.backups/.daily-counter.json，强制备份需卷卷二次确认 + force=true
  ⚠️ git bundle 前用 git filter-repo 扫 history 排除 secrets（避免泄露 .env/*.pem 等已 commit 的文件）
  ↓
[Phase 10: 存记忆]
  Docs-Researcher 把项目经验存入 ruflo memory
  内容: 任务简述 + 最终方案 + 踩坑 + 团队配置 + 模式选择
  ⚠️ memory_store 失败时不阻塞流程，convener 提示卷卷「记忆未存档」
  ↓
[Phase 11: 汇报归档]
  Convener 给卷卷最终结果
```

## 五、Phase 依赖图（DAG）

```
                    ┌──→ Phase 0 (头脑风暴，Convener)
                    │     ↓
   (并行启动) ───────┤   [需求清晰]
                    │     ↓
                    └──→ Phase 0.5 (资料查询，docs-researcher) ──┐
                          ↓                                       │
                       [两者汇合]                                 │
                          ↓                                       │
                       Phase 1 (模式选择) ←──────────────────────┘
                          ↓
                       Phase 2 (建目录)
                          ↓
                       Phase 3 (方案生成) ←─────┐
                          ↓                    │
                       Phase 4 (方案审核) ─────┤ (回退：reviewer 发现方案问题)
                          ↓                    │
                       Phase 5 (设计文档) ←───┘
                          ↓
                       Phase 6 (文档审核) ←─────┐
                          ↓                    │ (回退：reviewer 发现文档问题)
                       Phase 7 (实施: frontend + coder 并行) ──┤
                          ↓                    │
                       Phase 8 (代码审查) ─────┘ (回退：reviewer 发现代码问题)
                          ↓
                       Phase 9 (事件驱动备份 + 最终归档)
                          ↓
                       Phase 10 (存记忆)
                          ↓
                       Phase 11 (汇报归档)
```

**Phase 0 + 0.5 预取式并行**：Convener 跑 brainstorming 的同时，docs-researcher 后台预取 memory（结果暂存 .phase0.5-findings.json，Phase 0 完成后汇合，不是真并行）
**Phase 7 内并行**：frontend + coder（依赖 architect 接口契约先定义）
**Phase 4/6/8 三方并行审核**：architect + reviewer + docs-researcher 独立审（global-rules §4.1）
**不可跳过**：Phase 0（头脑风暴）、Phase 4（审核）、Phase 8（代码审查）

## 六、项目目录强制要求

**禁止**在根目录直接操作。必须建在：

```
~/项目/YYYY-MM-DD-HHmm-<任务简述>/
```

例：
```
~/项目/2026-08-03-1430-kaoyan-english-fix-login-bug/
```

git 仓库位置（默认选项 A）：
- **A**：项目目录内（`~/项目/2026-08-03-1430-.../.git/`）
- **B**：项目目录的上一级（`~/项目/.git/`）

## 七、智能备份机制

### 触发条件（满足任一即备份）
1. 单次任务内 git diff 累计 > 200 行
2. 单次任务内文件改动数 > 5 个（git tracked，含新增/修改/删除）
3. convener 跟卷卷确认「阶段性完成」时
4. reviewer 完成审查时（Reviewer verdict=pass 事件触发）
5. 卷卷显式说「备份一下」/「存档」

### 备份内容
- **tar.gz**：整个项目目录（默认排除 dist/build/node_modules/.git/secrets）
  - secrets 黑名单：`.env`、`.env.*`、`*.pem`、`*.key`、`*.crt`、`id_rsa`、`id_ed25519`、`.ssh/`、`.npmrc`、`.pypirc`、`.aws/credentials`、`.gnupg/`、`*.keystore`、`*.jks`、`*.kdbx`、`*.p12`、`*.pfx`、`credentials.json`、`.htpasswd`、`.netrc`、`.docker/config.json`、`.kube/config`、`*token*.json`、`*secret*.json`
  - 兜底：任何文件名含 `token` / `secret` / `credential` / `key` 的文件默认排除
  - 构建产物默认排除，仅在显式 `--full` 时包含
- **git bundle**：完整 git 历史（**必须先扫 history 排除 secrets**）
  - 命令：`git bundle create .backups/YYYY-MM-DD-HHmm-<任务>-git-bundle.bundle --all`
  - ⚠️ bundle 前用 `git filter-repo` 或扫描 `git rev-list --all -- '**/.env' '**/*.pem' '**/*.key'`，确认 history 无 secrets 再 bundle
  - 若 history 含 secrets：禁止 bundle，先清理 history 或改用 `git bundle --not $(git rev-list --all -- secrets_files)`

### 备份命名格式
```
YYYY-MM-DD-HHmm-<任务简述>.tar.gz
YYYY-MM-DD-HHmm-<任务简述>-git-bundle.bundle
```

### 备份位置
- 默认：`<项目目录>/.backups/`
- 可选：`~/项目/.backups/`（上一级统一备份库）

### 频率控制
同一项目内同一日最多备份 3 次（本地时区）。超出时 convener 提示：「今日备份已达 3 次上限，是否强制再备份？」

## 八、记忆机制

### 任务启动时自动读取（Phase 0）
docs-researcher 自动调 `memory_search`：
```
query: <任务关键词>
threshold: 0.3
limit: 5
```
匹配到的历史项目经验注入 convener 对话上下文。

### 任务完成时存档（Phase 10）
docs-researcher 存入 ruflo memory：
```yaml
key: <项目目录名>
namespace: project
value: |
  任务简述: <一句话描述>
  最终方案: <选定的方案 + 关键决策>
  踩坑: <实施过程中遇到的问题 + 解决方法>
  团队配置: <本次实际用的 Agent 角色组合>
  模式选择: <Safe/Manual/Auto/YOLO + 是否阶段性切换>
  项目路径: ~/项目/YYYY-MM-DD-HHmm-.../
tags: [skill, juanjuan-team, <技术栈标签>]
provenance_type: agent_output
```

## 九、Skill 文件结构

```
~/.claude/skills/juanjuan-team/
├── SKILL.md                          # 本文件（主入口）
├── references/
│   ├── global-rules.md               # 全局共享规则（10 条硬约束 + 模式冲突处理）
│   ├── role-leader.md                # 7 个角色完整 prompt
│   ├── role-convener.md
│   ├── role-architect.md
│   ├── role-frontend.md
│   ├── role-coder.md
│   ├── role-reviewer.md
│   ├── role-docs-researcher.md
│   ├── decision-engine.md            # 决策引擎（对抗式辩论 + 加权评分）
│   ├── state-machine.md               # 任务状态机
│   ├── skill-allocation.md           # 角色技能分配矩阵
│   ├── agent-commands.md             # Agent 命令规范（跨平台兼容）
│   ├── customization.md              # 灵活配置指南（改 prompt/数量/理论）
│   ├── message-protocol.md           # ★ Agent 间通信协议（文件消息 + MCP + SendMessage）
│   ├── fault-tolerance.md            # ★ 容错机制（convener 单点 + 失联 + 模式切换 + 并发隔离）
│   ├── lite-mode.md                  # ★ Lite 模式（单文件任务走 6 Phase 精简流程）
│   ├── domain-checklists.md          # ★ 9 信号组 + 领域 checklist + 反群体思维 + HTML 报告（可选）
│   └── backup-script.sh               # 备份脚本
└── scripts/
    ├── install.sh                    # ★ 一键安装（clone + symlink 到 ~/.claude/skills/）
    ├── swarm-spawn.sh                 # 7 人 agent spawn 脚本
    └── backup-check.sh                # 备份触发条件检查
```

★ = v1.3 新增

## 十、MCP 工具调用路径

本 skill 通过 Claude Code 的 MCP 工具调用 Ruflo（已连接，验证可用）：

| 工具 | 用途 | 调用时机 |
|------|------|---------|
| `mcp__claude-flow__swarm_init` | 初始化 7 人 swarm | Phase 2 建目录后 |
| `mcp__claude-flow__agent_spawn` | spawn 单个 Agent | Phase 2 后，并行 spawn 7 人 |
| `mcp__claude-flow__agent_execute` | 给 Agent 派任务 | Phase 3-11 各 Phase |
| `mcp__claude-flow__memory_search` | 查历史经验 | Phase 0 头脑风暴 |
| `mcp__claude-flow__memory_store` | 存项目经验 | Phase 10 存记忆 |
| `mcp__claude-flow__swarm_status` | 查 swarm 状态 | 任意 Phase 监控 |
| `mcp__claude-flow__hive-mind_consensus` | YOLO 模式投票 | Phase 4 冲突处理 |

## 十一、错误处理

| 场景 | 处理 |
|------|------|
| ruflo MCP 不可用 | convener 提示「MCP 不可用，降级为本地 JSON 模式」（见 fault-tolerance.md §五），**流程继续不阻塞** |
| 记忆库查询失败 | docs-researcher 报告「无历史经验」，继续流程 |
| 备份失败（磁盘满） | convener 提示并询问是否清理旧备份或换位置 |
| Agent 间无法达成共识 | Leader 自检 → 明显情况定夺，技术性选择转卷卷 |
| 项目目录已存在 | convener 询问「追加到现有项目还是新建带后缀的目录」 |
| git 仓库已存在 | convener 询问「复用现有 git 历史 还是 重新 init」 |
| 模式切换冲突 | 以最新一次模式选择为准，convener 通知团队 |
| 记忆库写入失败 | convener 提示卷卷「记忆未存档，请检查 ruflo MCP」，流程继续不阻塞 |

## 十二、与 SuperPower brainstorming 的衔接

- brainstorming skill 完成需求澄清后，convener 主动询问「这次要不要上 juanjuan team？」
- 或者卷卷主动说「上 juanjuan team」/「用 ruflo 跑这个」
- 衔接点：brainstorming 输出的需求 spec → juanjuan-team 的 Phase 0 输入

## 十三、Claude Code 内置命令的使用口径

> ⚠️ 之前的表述「禁用」有歧义。明确口径：

**最新版 Claude Code 把 `/review`、`/security-review`、`deep search` 等内置命令改成「必须手动 `/` 调用才生效」（不是禁用，是不再自动触发）**。本 skill 的 Agent 在对应场景必须**主动用 `/` 前缀调用**，否则不生效。

| 命令 | 状态 | 本 skill 使用方式（按优先级） |
|------|------|------------------------------|
| `/review` | 需手动 `/` 调用 | ① Reviewer 主动调 `/review`；② 失败则 spawn `code-reviewer` subagent |
| `/security-review` | 需手动调用 | ① Reviewer 主动调 `/security-review`；② 失败则 spawn `security-reviewer` subagent |
| `deep search` | 需手动调用 | docs-researcher 用 `memory_search` + `kimi-webbridge` skill |

> ⚠️ 优先级：先试 `/` 命令，失败才 spawn subagent fallback，不要并列调用

调用方式（convener 在 Phase 4/6/8 用）：
```
Reviewer 主动调: /review + /security-review
或 spawn subagent 作为 fallback:
Agent({ description: "reviewer 审 <目标>", prompt: "<reviewer 角色 prompt + 被审目标>", subagent_type: "code-reviewer" })
```

## 十四、未来扩展（YAGNI，本次不做）

- 全局自动读取记忆：配 PreToolUse hook
- 跨项目记忆聚合分析
- Web UI 可视化聊天日志
- 支持 GitLab / Bitbucket 等非 GitHub 仓库
- 团队配置热加载（运行中调整角色）
- JAAOS 三引擎融合架构（Ruflo + Hermes Kanban + AgentTeams）
