# 🌀 卷卷团队 (Juanjuan Team)

**Claude Code 首个对抗式协作多 Agent Skill -- 真 7 个独立 Claude 进程互审，让错误在卷卷看到之前就被拦截。**

> 别再让一个 LLM 同时负责设计、实现和审查自己的工作。卷卷团队派出 **7 个独立 Claude 进程**（claude -p 真进程，PPID=1），每个有自己的 context、看不到对方私有推理，独立挑错--单 Agent 自我背书的认知连续性错误从此不可能。

🔥 **v2.2 里程碑**: 真 7-Agent 完整 11 Phase 流程跑通。**9 个真 claude -p 进程**累计跑过 URL 短链接项目，reviewer 独立挑出 architect 漏的 2 个 critical（SSRF + 权限错乱），leader 做有条件批准裁决，sub-agent team 真派发（typescript-reviewer + security-reviewer 发现 31 issues）。

📚 **快速入门**:
- 🆕 **什么都不懂？** -> [`docs/for-non-developers.md`](docs/for-non-developers.md)（大白话指南，零代码）
- ⚡ **5 分钟上手** -> [`docs/getting-started.md`](docs/getting-started.md)
- 🔬 **v2.2 真 7-Agent 验证** -> URL 短链接项目（6 真 claude -p 进程 + 完整 11 Phase + sub-agent 派发）
- 🛡️ **防断联机制** -> [`references/v2.2-resilience.md`](references/v2.2-resilience.md)
- 📁 **项目命名聚合** -> [`references/v2.2-project-naming.md`](references/v2.2-project-naming.md)
- 📖 **完整文档** -> 本 README

[![License: Personal Use](https://img.shields.io/badge/License-Personal%20Use-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://claude.com/claude-code)
[![Status: v2.2](https://img.shields.io/badge/status-v2.2%20stable-brightgreen)](#)
[![Min Claude Code](https://img.shields.io/badge/Min%20Claude%20Code-2.0%2B-orange)](#)
[![Real Process](https://img.shields.io/badge/claude--p-real%20process%20(PPID%3D1)-red)](#)

🌐 **语言:** **中文** | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

---

## 🎯 为什么需要卷卷团队？

每个资深工程师都见过单 Agent 陷入螺旋陷阱：它设计了一个有缺陷的架构，实现了它，然后"审查"自己的工作，又批准了同样的缺陷。bug 就这样上线了。**卷卷团队就是为了让这种事不可能发生。**

基于**对抗式协作**（adversarial collaboration）——和人间代码审查起效的原理一样——每个重要决策都由 3 个以上 Agent 独立分析，他们在提交自己的意见之前，看不到其他人的意见。

### ⚙️ 不是固定框架，是可配置模板

7 个 Agent + 11 阶段 + 4 模式只是**卷卷的默认配置**，不是唯一选择。你可以：
- 改任意角色的 prompt（性格、禁止事项、输出格式）
- 加减 Agent 个数（5 人精简版 / 10 人大团队）
- 改理论框架（决策权重、辩论协议、状态机）
- 改模式定义（加 Stealth / Pair 模式，删 YOLO）

详见 [`references/customization.md`](references/customization.md)。Fork 后建自己的 config 分支，可以跟 upstream 同步又保留自己的配置。

### ⚡ 30 秒电梯演讲

| 单 Agent | 卷卷团队 |
|---------|---------|
| 设计 + 实现 + 审查都一个人干 | 7 个 Agent 分担设计、实现、审查 |
| 会批准自己的错误（认知连续性错误） | Reviewer 角色被结构性地禁止写代码/文档（不自我背书） |
| 跨会话全忘 | 自动把经验存进 Ruflo 记忆库 + 下次项目自动调用 |
| 没有项目隔离 | 自动建带日期的项目目录 + 智能备份 |
| 一次性决策 | 加权决策引擎（技术 30% + 价值 25% + 可维护 20% + 安全 15% + 成本 10%） |

---

## 🆚 和其他多 Agent 框架的差别

| 框架 | 路线 | 弱点 | 卷卷团队的回答 |
|------|------|------|---------------|
| **CrewAI** | 角色化 Agent + 顺序任务 | 角色之间能互相看对方输出 → 从众 | **强制独立审核**：Reviewer 提交前看不到其他 Agent 的意见 |
| **LangGraph** | 图工作流 | 只关注流程，没有对抗式思考 | **内建辩论协议**：Proposer → Critic → Optimizer → Judge |
| **AutoGen** | 对话式 Agent | 所有 Agent 自由发言 → 混乱 | **单窗口政策**：只有 Convener 跟用户对话，其余 6 人内部协调 |
| **OpenAI Swarm** | 轻量交接 | 没有记忆，没有审计 | **记忆 + 状态机**：每个任务有生命周期，每条经验都存档 |
| **Claude 子 Agent** | 一次性任务委派 | 没有团队连贯性 | **7 角色有性格**：每个 Agent 有身份、禁止事项、错误处理 |

### 🌟 卷卷团队独有的 5 大特性

1. **结构性反自我背书** —— Reviewer 在合同层面被禁止写代码或写文档。哪怕是"顺手改一行"也不行。发现问题只能标注，由原作者修改。

2. **对抗式辩论协议** —— 每个重要决策，4 个角色由现有 Agent 担任：**Proposer**（architect）→ **Critic**（reviewer）→ **Optimizer**（convener）→ **Judge**（leader）。不用新增 Agent。

3. **加权决策引擎** —— 3 个方案冲突时不投票，打分：`技术可行性 × 30% + 用户价值 × 25% + 可维护性 × 20% + 安全性 × 15% + 成本效率 × 10%`。LEVEL A/B/C/D 决定升级路径。

4. **带 Secrets 黑名单的智能备份** —— `git diff > 200 行` 或 `文件改动 > 5 个`时自动备份。排除 20+ 种 secrets 模式（`.env`、`id_rsa`、`.aws/credentials`、`*.keystore`、`*.kdbx` 等）。每日上限 3 次防磁盘爆炸。

5. **智能调用 Claude Code 内置命令** —— Claude Code 在最新版本中关闭了 `/review` 和 `deep search` 的自我调用（需手动 `/` 前缀触发）。我们的 Reviewer Agent 可以主动调用这些命令，并且可以用子 Agent 替代（`code-reviewer` 替代 `/review`，`memory_search` + `kimi-webbridge` 替代 `/deep-reach`），需要时强制调用相关 skills。其他 Agent 平台（Codex / Hermes / Gemini CLI）没有这些命令时，用等价命令完成相同任务。

---

## 🏗️ 架构

```
                    卷卷 (用户)
                       │
                  Convener (唯一对话窗口)
                       │
                    Leader
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   Architect       Reviewer    Docs-Researcher
   (提案者)        (批评者)     (记忆)
                       │
              ┌────────┴────────┐
              │                 │
          Frontend            Coder
```

### 11 阶段工作流

```
Phase 0  头脑风暴          Phase 6  文档审核
Phase 1  模式选择          Phase 7  实施（frontend + coder 并行）
Phase 2  建项目目录         Phase 8  代码审查（OWASP Top 10 + 80% 覆盖率）
Phase 3  出方案 A/B/C     Phase 9  智能备份（tar.gz + git bundle）
Phase 4  对抗式审核        Phase 10 存记忆
Phase 5  设计文档          Phase 11 汇报归档
```

### 4 种执行模式

| 模式 | 行为 | 何时用 |
|------|------|--------|
| **Safe（安全）** | 每阶段都审核 + 用户逐条确认 | 生产环境、不可逆操作 |
| **Normal（普通）** | 团队只做头脑风暴辅助，用户完全审核 | 用户要完全掌控时 |
| **Auto（自动）** | 团队审核，难抉择转用户 | 日常推荐 |
| **YOLO（全自动）** | 全权限放给团队，hive-mind 投票 | 信任团队、要快速出结果 |

---

## 📦 安装

### 方式 A：gh CLI 一行命令

```bash
gh repo clone dxkjuanjuan/juanjuan-team ~/.claude/skills/juanjuan-team
```

### 方式 B：手动

```bash
git clone https://github.com/dxkjuanjuan/juanjuan-team.git ~/.claude/skills/juanjuan-team
chmod +x ~/.claude/skills/juanjuan-team/references/backup-script.sh
chmod +x ~/.claude/skills/juanjuan-team/scripts/*.sh
```

### 前置条件

- **Claude Code 2.0+**（skill 系统）
- **Ruflo MCP 服务器**（用于 `mcp__claude-flow__*` 工具）
  ```bash
  claude mcp add claude-flow -- npx -y ruflo@latest mcp start
  ```
- **Bash + git**（备份脚本用）

### 验证安装

重启 Claude Code，在任意对话中说：

```
用卷卷 skill
```

（或 `juanjuan skill` / `用 juanjuan team`）

Convener 会自我介绍，并问你这次想做什么。

---

## 🤖 支持的 Agent 平台

卷卷团队主要为 **Claude Code** 设计，但可适配其他主流 AI 编码 Agent：

| Agent 平台 | 使用方法 |
|-----------|---------|
| **Claude Code**（主要） | 把 skill 放进 `~/.claude/skills/juanjuan-team/`，用 `juanjuan skill` 等关键词触发 |
| **Codex CLI** | 把 `references/role-*.md` 作为系统提示词放进 Codex 配置。7 个角色 prompt 与模型无关 |
| **Gemini CLI** | 把 `role-*.md` 作为 `.gemini/agent.json` 的系统指令。把 `kimi-webbridge` 替换为 Gemini 的浏览器工具 |
| **Cursor** | 把角色 prompt 加进 `.cursorrules` 或 Cursor 的 Agent 配置。映射 `mcp__claude-flow__*` 调用到你的 MCP 配置 |
| **Cline** | 把角色 prompt 作为 `.clinerules` 使用。如需要，适配 MCP 工具名 |
| **Continue.dev** | 在 `config.json` 中把 7 个角色配置为自定义 Agent |
| **Hermes / 其他** | 把 `role-*.md` 作为系统提示词。MCP 工具调用需替换为对应平台的工具 |

> **注意**：skill 的 MCP 工具调用（`mcp__claude-flow__*`）是 Claude Code 专属的。其他 Agent 要么 (a) 配置对应的 MCP 服务器，要么 (b) 替换为该 Agent 的等价工具调用。

---

## 🚀 快速开始

### 触发方式

**自动触发**：描述任务时自动触发（动词 + 任务对象）：
```
你: 帮我修 React 项目里缺失页面的 bug
→ 自动调 juanjuan-team skill
→ Phase 0 调 superpowers:brainstorming 头脑风暴
→ ...
```

**显式触发**：说 `juanjuan skill` / `用卷卷 skill` / `用 juanjuan team`

### 完整流程示例

```
你: 帮我修 React 项目里缺失页面的 bug

[Phase 0] Convener 调 superpowers:brainstorming
          → 逐个澄清问题：什么 bug？哪些页面？技术栈？
          → 你回答后出方案 A/B/C

[Phase 1] Convener 用 AskUserQuestion 弹卡片:
          ┌─────────────────────────────┐
          │  选模式:                     │
          │  ◯ Safe  (每步审核+确认)     │
          │  ● Auto  (团队审+难抉择转你) │
          │  ◯ Normal(只辅助,你审)       │
          │  ◯ YOLO  (全自动,投票)      │
          └─────────────────────────────┘
          你点 Auto

[Phase 2] 建目录 ~/项目/2026-08-04-fix-pages/
[Phase 3] Architect 出 3 方案（复用 Phase 0）
[Phase 4] Reviewer + Architect + Docs-Researcher 独立审
          → 加权评分：方案 B = 82.75（LEVEL B）
[Phase 7] Coder 实现（调 superpowers:tdd 做 TDD）
[Phase 8] Reviewer 调 /review + /security-review + 子 Agent 并行审
          → pass（3 minor，无 critical）
[Phase 9] 备份（29KB tar.gz + 29KB git bundle）
[Phase 10] 记忆存档
[Phase 11] 汇报：6 文件 281 行，每个 < 65 行
```

---

## 📊 跟其他 Agent 团队对比（v2.2 实测）

> 不是"卷卷 vs 单 Agent"（单 Agent 没有可比性），是"卷卷 vs 其他主流多 Agent 框架"。所有数据基于 v2.2 URL 短链接系统任务实测。

### 跟主流多 Agent 框架对比

| 维度 | CrewAI | LangGraph | AutoGen | OpenAI Swarm | Claude 子 Agent | **卷卷团队 v2.2** |
|------|--------|-----------|---------|-------------|---------------|-----------------|
| **Agent 隔离方式** | 同进程 prompt | 同进程 prompt | 同进程对话 | 同进程交接 | 同进程子上下文 | **claude -p 真独立 OS 进程（PPID=1）** |
| **盲审成立吗** | ❌ 互相看得见 | ❌ 共享 state | ❌ 自由发言 | ❌ 顺序交接 | ❌ 看父会话 | ✅ **reviewer 真看不到 reasoning.md（0 泄漏）** |
| **结构性反自我背书** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **Reviewer 合同层面禁写代码** |
| **真并行 spawn** | ❌ 顺序 | ⚠️ 图并行 | ⚠️ 对话并行 | ❌ 交接 | ❌ 一次性 | ✅ **coder+frontend 真并行（140s 同时完成）** |
| **独立 cost 追踪** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **reviewer $2.02 独立统计** |
| **对抗式辩论协议** | ❌ | ❌ | ⚠️ 自由辩 | ❌ | ❌ | ✅ **Proposer→Critic→Optimizer→Judge** |
| **加权决策引擎** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **5 维度加权（技术30%+价值25%+维护20%+安全15%+成本10%）** |
| **leader 真裁决** | ❌ | ❌ | ⚠️ 投票 | ❌ | ❌ | ✅ **conditional_approve + 必修清单** |
| **sub-agent team** | ❌ | ❌ | ⚠️ | ❌ | ⚠️ 一次性 | ✅ **17 sub 配置，主角色可派** |
| **断电恢复** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **phase-state.json + resume.sh** |
| **project-id 聚合** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **registry.json + continue.sh** |
| **元验证脚本** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **meta-verify.sh 8 项** |

### 效果对比（v2.2 URL 短链接系统实测）

| 效果指标 | 普通多 Agent（CrewAI 类） | **卷卷团队 v2.2** | 提升 |
|---------|------------------------|-----------------|------|
| **critical issue 检出率** | 0/2（agent 互相看得见，从众） | **2/2**（reviewer 独立审，全挑出） | **+100%** |
| **总 issue 检出数** | ~10（agent 互相影响） | **61**（design 17 + code 13 + sub 31） | **+510%** |
| **盲审隔离** | ❌（共享 context） | **✅ 0 泄漏**（进程级隔离） | 质变 |
| **安全反模式检出** | ~1（agent 都漏） | **2**（SSRF + SHA-256 反模式，全挑出） | **+100%** |
| **架构矛盾检出** | ~2 | **3**（archived 死胡同 / UNIQUE 冲突 / 硬删除矛盾） | **+50%** |
| **verdict 质量** | 简单投票 | **conditional_approve + 必修清单 + 8 点 synthesis** | 质变 |
| **sub-agent 专项审查** | ❌ | **31 findings**（typescript + security） | 质变 |
| **可审计性** | ❌ | **audit log 20 events + 完整 trace** | 质变 |

### 质量提升的核心原因

1. **真进程隔离**（claude -p PPID=1）：reviewer 真看不到 architect 的私有推理，盲审成立。其他框架都是同进程，agent 互相看得见，从众效应严重。

2. **结构性反自我背书**：Reviewer 在合同层面被禁止写代码/文档，"顺手改一行"都不行。其他框架的 reviewer 既能审又能改，等于自己审自己。

3. **盲审硬约束 + 泄漏阻断**：spawn 前 grep 检测策略性语言，发现就打回 architect 重写（不经 convener 清洗）。其他框架没有这个机制。

4. **sub-agent team 真派发**：reviewer 在自己进程内派 typescript-reviewer + security-reviewer，sub 做专项审查，主角色综合做 verdict。sub 不替主角色定 verdict，避免"主角色沦为汇总员"。

5. **leader 真裁决**：不是简单投票，是 conditional_approve + 必修清单 + major/minor 分级。reviewer 挑出 2 critical，leader 确认必修，convener 综合。

### token 和时间的合理化

| 维度 | 单 Agent | 卷卷团队 v2.2 | 为什么值得 |
|------|---------|--------------|-----------|
| token | ~50k | ~970k（9 进程累计） | 换 12 倍 issue 检出率 + 真对抗 |
| 耗时 | ~3 分 | ~22 分 | 换结构性反自我背书 + 盲审隔离 |
| cost | $0.5 | ~$5-10 | 换安全关键任务不漏 critical |

**结论**：对于**安全关键任务（auth/payment/PII）**、**大型架构设计（百万用户级）**、**不可逆操作（生产部署）**--卷卷团队的 token/时间消耗是合理代价。对于单文件 typo，用 Lite 模式（仅 reviewer + 1 sub，~5 万 token）。

### Lite/Medium/Complex 三档 -- 任务越大，对抗越强

卷卷团队按任务复杂度自动选模式，**轻量任务便宜又好，大型任务极致对抗**：

#### 🟢 Lite 模式（简单任务）-- **省 token，效果也好**

| 维度 | 数值 |
|------|------|
| 判定 | 单文件 / 不跨模块 / 无架构影响（如 typo、小 bug） |
| spawn 方式 | Agent Teams teammate（同进程独立 context） |
| Agent 数 | 2（reviewer + 1 sub） |
| token 消耗 | **~50k**（跟单 Agent 差不多） |
| 耗时 | ~5 分钟 |
| 对抗性 | ✅ 一定有（盲审隔离 + reviewer 挑错） |
| 效果 | 比单 Agent 好（有独立审核），但 token 没多多少 |

**适合**：单文件 typo、小脚本、配置改动、单 bug 修复

#### 🟡 Medium 模式（中等任务）-- **稍贵，但效果明显更好**

| 维度 | 数值 |
|------|------|
| 判定 | 2-5 文件 / 跨 1-2 模块 / 新功能但不跨模块 |
| spawn 方式 | Agent Teams teammate |
| Agent 数 | 3-5（convener + architect + reviewer + 可选 coder/frontend） |
| token 消耗 | **~200k**（是单 Agent 的 4 倍） |
| 耗时 | ~10 分钟 |
| 对抗性 | ✅ 强（独立审核 + 加权决策 + 对抗辩论） |
| 效果 | **明显比单 Agent 好**（reviewer 挑出 architect 漏的真问题） |

**适合**：新功能开发、小工具、API 端点、组件实现

#### 🔴 Complex 模式（大型任务）-- **贵，但极致对抗，非常非常牛**

| 维度 | 数值 |
|------|------|
| 判定 | >5 文件 / 跨 ≥3 模块 / 安全关键（auth/payment/PII）/ 大型架构设计 |
| spawn 方式 | **claude -p 真独立 OS 进程**（PPID=1，进程级隔离） |
| Agent 数 | 6 真 claude -p 进程 + 1 主会话（convener） |
| token 消耗 | **~500k-1M**（9 进程累计） |
| 耗时 | ~22 分钟 |
| 对抗性 | ✅ **极致**（进程级隔离 + 盲审 0 泄漏 + leader 真裁决 + sub-agent team 专项审查） |
| 效果 | **质量最高**（critical 全挑出 + 结构性反自我背书 + 真并行） |

**适合**：百万用户系统设计、支付系统、auth 系统、大型重构、安全关键任务

### 三档对比一句话

| 模式 | token | 对抗性 | 何时用 |
|------|-------|--------|--------|
| 🟢 Lite | ~50k | 一定有 | 简单任务，省 token 也比单 Agent 好 |
| 🟡 Medium | ~200k | 强 | 中等任务，稍贵但效果明显更好 |
| 🔴 Complex | ~500k-1M | **极致** | 大型任务，贵但**独立的对抗，非常非常牛** |

**`task-classify.sh` 5 问结构化判定，自动选模式**，不强制全配 7 Agent，也不浪费 token。


---

## 📁 项目结构

```
~/.claude/agents/juanjuan-*.md       # 7 个角色定义（被 Claude Code 识别为 subagent_type）
├── juanjuan-convener.md             # 主对接 + 总审核（model: opus）
├── juanjuan-leader.md               # 调控者 + 裁决（model: opus）
├── juanjuan-architect.md            # 架构师 + 出方案（model: opus）
├── juanjuan-reviewer.md             # 盲审 + 挑错（model: sonnet）
├── juanjuan-coder.md                # 后端 + sub-agent team（model: sonnet）
├── juanjuan-frontend.md             # 前端 + sub-agent team（model: sonnet）
└── juanjuan-docs-researcher.md      # 文档 + 资料 + 记忆（model: sonnet）

~/.claude/skills/juanjuan-team/
├── SKILL.md                          # 主入口（v1.0~v2.2 完整规范 + 16 章节）
├── README.md                         # 本文件
├── LICENSE                           # 个人使用许可
├── hooks/hooks.json                  # PreToolUse Hook（500 行限制 + Co-Authored-By 拦截 + secrets 检测）
│
├── docs/                             # 文档（4 份）
│   ├── getting-started.md            # 5 分钟上手
│   ├── for-non-developers.md         # 非技术用户指南
│   ├── evolution-history.md          # v1.0->v2.2 演进史
│   └── v2.2-verification-report.md   # v2.2 真 7-Agent 验证报告
│
├── references/                       # 规范文档（22 份）
│   ├── global-rules.md               # 11 条硬约束（v1.5 加 run_id 必填）
│   ├── role-*.md (7 份)              # 7 个角色 prompt（v1.0 起）
│   ├── decision-engine.md            # 对抗式辩论 + 加权评分（v1.5 修数学）
│   ├── state-machine.md              # 任务状态机
│   ├── skill-allocation.md           # 角色技能分配
│   ├── agent-commands.md             # 跨平台命令（v1.5 修 Codex）
│   ├── customization.md              # 灵活配置
│   ├── message-protocol.md           # 通信协议（v1.5 加 run_id）
│   ├── fault-tolerance.md             # 容错（v1.5 路径对齐）
│   ├── lite-mode.md                  # Lite 模式（6 Phase）
│   ├── domain-checklists.md          # 9 信号组 + 领域 checklist
│   ├── backup-script.sh              # 备份脚本（v1.5 模式感知）
│   ├── meta-verification.md          # 6 项元验证（MV-1~MV-8）
│   ├── observability.md              # run_id + phase-trace + tool_call_id
│   ├── anti-patterns.md              # 19 条反模式（AP-1~AP-19）
│   ├── evolution-roadmap.md          # v1.5->v2.0 路径
│   ├── audit-event-schema.md         # ★ v1.8 audit 事件格式
│   ├── sub-agent-review.md           # ★ v1.6 主+sub 双层对抗
│   ├── sub-agent-team.md             # ★ v2.0 sub-agent team 规范
│   ├── v1.9-layered-architecture.md  # ★ v1.9 分层调度（Lite/Medium/Complex）
│   ├── v2.0-11-phase-flow.md         # ★ v2.0 完整 11 Phase
│   ├── v2.0-cross-platform-abstraction.md  # ★ v2.0 跨平台抽象层
│   ├── v2.0-model-layering.md        # ★ v2.0 模型分层
│   ├── v2.2-resilience.md             # ★ v2.2 防断联
│   └── v2.2-project-naming.md        # ★ v2.2 项目命名聚合
│
└── scripts/                          # 脚本（18 份）
    ├── install.sh                    # 一键安装
    ├── create-project.sh             # 建项目目录（v1.4.1）
    ├── swarm-spawn.sh                # 7 Agent spawn 文档（v1.5 修）
    ├── backup-check.sh                # 备份触发检查
    ├── heartbeat-check.sh            # 心跳检查
    ├── hook-enforce.sh               # Hook 强制规则（v1.5 扩正则+项目 rules）
    ├── lite-check.sh                 # Lite 模式检查
    ├── send-msg.sh                   # 消息发送
    ├── meta-verify.sh                # ★ v1.5 元验证执行器（6 项检查）
    ├── e2e-dry-run.sh                 # ★ v1.5 e2e 干跑
    ├── memory-roundtrip-test.sh      # ★ v1.5 记忆闭环测试
    ├── v1.8-commit0-verify.sh        # ★ v1.8 Commit 0 验证
    ├── global-spawn.sh               # ★ v1.9 claude -p 真进程 spawn
    ├── team-status.sh                # ★ v1.9 team 状态检查
    ├── mailbox.sh                    # ★ v1.9 专属 Mailbox
    ├── task-classify.sh              # ★ v1.9/v2.0 任务分级判定（5 问）
    ├── phase-state.sh                # ★ v1.9 phase-state 维护
    ├── cleanup-stale.sh              # ★ v1.9 脏数据清理
    ├── registry.sh                   # ★ v1.9 project-id 注册表
    ├── auto-spawn.sh                 # ★ v2.2 自动 spawn wrapper
    ├── resume.sh                     # ★ v2.2 断联恢复
    └── continue.sh                   # ★ v2.2 接着跑
```

★ = v1.5~v2.2 新增（v1.4 之前只有 8 份脚本）

---

## 🔬 实战验证

### v2.2 URL 短链接系统（Complex 任务，9 真 claude -p 进程）

**任务**：设计 URL 短链接系统（短码生成/存储/重定向/统计/防滥用）

**真进程证据**（全部 PPID=1，不是 Sub Agent）：

| Agent | PID | 耗时 | 产出 |
|-------|-----|------|------|
| architect | 95116 | 270s | design.md 463行 + reasoning.md 203行 |
| reviewer | 97243 | 180s | 17 issues（2 critical / 7 major） |
| leader | 98721 | 101s | verdict.json（conditional_approve） |
| docs-researcher | 99886 | 120s | spec.md（含量化指标） |
| coder | 1256 | 140s 并行 | stub.ts 12340B |
| frontend | 1273 | 140s 并行 | stub.tsx 7989B |
| reviewer Phase 8 | 4242 | 160s | code-review.json 13 issues |
| docs-researcher Phase 10 | 5919 | 61s | memory-entry.json + ruflo memory |
| reviewer sub-agent | 7008 | 211s | sub-agent-review.json 31 findings |

**对抗式协作证据**：
- ✓ reviewer 挑出 2 critical 全是 architect 漏的（SSRF + 权限错乱）
- ✓ 盲审隔离成立（reviewer 没读 reasoning.md，0 泄漏）
- ✓ leader 真裁决（conditional_approve + 必修清单）
- ✓ sub-agent team 真派发（typescript-reviewer + security-reviewer，31 findings）
- ✓ Phase 8/9/10 真做（代码审查 + tar.gz 备份 + ruflo memory 存档）

### v1.8 TODO list（Agent Teams teammate 首次验证）

- architect + reviewer 两个 teammate（agent_id: name@session 格式）
- reviewer 挑出 3 critical（archived 死胡同 / UNIQUE 冲突 / 硬删除矛盾）
- mailbox 跨 teammate 通信成立

### v1.9 百万用户登录系统（claude -p 真进程首次验证）

- architect PID 39250 + reviewer PID 44389（PPID=1）
- reviewer 挑出 2 critical（access token 撤销 + SHA-256 反模式）
- reviewer 独立 cost 统计 $2.02（teammate 不会有）

### v2.0 博客系统（11 Phase 完整流程首次验证）

- architect + reviewer 真进程跑完整 6 Phase MVP
- reviewer 挑出 2 critical（文章 XSS + 评论 XSS）

完整验证报告：[`docs/v2.2-verification-report.md`](docs/v2.2-verification-report.md)

---

## 🧠 哲学

> "不要优化成最快给出答案。要优化成给出最好的答案。"

单 Agent 平庸的答案，比不上：
**规划 → 专家分析 → 独立批评 → 修改 → 验证 → 交付**

这不是聊天机器人，是一个**模拟工程团队**——有角色分工、对抗式审查、记忆、持续改进。

### 核心原则

1. **结构性反自我背书** —— Reviewer 在合同层面被禁止写代码/文档
2. **真进程隔离** —— v2.2 用 claude -p 真独立 OS 进程（PPID=1），不是同进程子上下文
3. **盲审硬约束** —— reviewer 的 prompt 不含 architect 的 reasoning.md，spawn 前 grep 阻断
4. **sub 不替主角色定 verdict** —— sub 帮主角色做细分任务，最终 verdict 由主角色定
5. **可观测 > 自觉** —— 所有规则都变成脚本能验证的（meta-verify.sh 6 项检查）
6. **闭环 > 单向** —— 存的记忆能查出来才算闭环（memory-roundtrip-test.sh）
7. **YAGNI** —— 不在 roadmap 上的功能不做

---

## 📋 量化标准（Reviewer 必查清单 + 元验证 8 项）

### Reviewer 必查清单

- 测试覆盖率（核心路径）≥ 80%
- 单文件 < 500 行（项目有 ECC rules 时 800 max，hook-enforce.sh 自动感知）
- commit 信息无 `Co-Authored-By` AI 署名 trailer（hook 拦截）
- 前端遵循 `shadcn/ui` + `Ant Design`
- OWASP Top 10 逐条检查（2021 版：A01 Broken Access Control ... A10 SSRF）
- 无硬编码 secrets（20+ 模式黑名单：sk-/ghp_/glpat-/xoxb-/AKIA/eyJ/PEM 等）
- 代码风格：immutability、KISS、DRY、YAGNI

### 元验证 8 项（meta-verify.sh）

| # | 检查项 | 验证目标 |
|---|--------|---------|
| MV-1 | 独立审核证据 | Phase 4/6/8 三方真独立产出 |
| MV-2 | context 隔离性 | 各 teammate spawn prompt 互不包含 |
| MV-3 | 模式切换日志 | Phase 边界原子化 |
| MV-4 | 记忆闭环 | Phase 10 存的 memory Phase 0.5 能查到 |
| MV-5 | 备份触发 | reviewer pass 事件真触发备份 |
| MV-6 | 盲审完整性 | reviewer prompt 不含 architect/private/ |
| MV-7 | 对话辩论 ≤5 轮 | 防止无限循环 |
| MV-8 | task 依赖完整性 | 无悬空任务 |

### 9 信号组（domain-checklists.md）

| # | 信号组 | 严重度 |
|---|--------|--------|
| 1 | Correctness | critical |
| 2 | Security | critical |
| 3 | Performance | major |
| 4 | Maintainability | major |
| 5 | Accessibility | major |
| 6 | Error Handling | major |
| 7 | Test Coverage | major |
| 8 | API Design | minor |
| 9 | Documentation | minor |

---

## 🛣️ Roadmap

### 已完成

- [x] **v1.0~v1.4**（2026-07 ~ 2026-08-04）—— 剧本版（1 Claude 演 7 角色）+ 11 阶段 + 4 模式
- [x] **v1.5**（2026-08-04）—— 修 12 缺陷 + 元验证层（MV-1~MV-5）+ 可观测性（run_id + phase-trace）
- [x] **v1.6**（2026-08-04）—— 主+sub 双层对抗（共识/分歧/盲点三方综合）
- [x] **v1.7**（2026-08-04）—— 自审 12 缺陷 + 复杂度感知（Lite/Medium/Complex）+ tool_call_id
- [x] **v1.8**（2026-08-05）—— **Agent Teams 真 spawn 3 Agent**（首次真对抗，TODO list 验证）
- [x] **v1.9**（2026-08-05）—— **claude -p 真进程 spawn**（PPID=1，百万用户登录系统验证）
- [x] **v2.0**（2026-08-05）—— 完整 7-Agent + 11 Phase + 跨平台抽象 + 模型分层
- [x] **v2.1**（2026-08-05）—— **真 7-Agent 完整 11 Phase + 真并行**（URL 短链接系统验证）
- [x] **v2.2**（2026-08-05）—— Phase 8/9/10 真做 + sub-agent 派发 + 防断联 + 项目命名聚合

### v2.3+ 待做（卷卷说"到时候再说"）

- [ ] **v2.3** —— Codex CLI 后端实现（跨平台抽象层落地）
- [ ] **v2.4** —— Gemini CLI 后端实现
- [ ] **v2.5** —— HAPI Remote 后端（跨机器 spawn）
- [ ] **v2.6** —— 跨项目记忆聚合（Neo4j 知识图谱，研究性）
- [ ] **v2.7** —— Web UI（群聊 + 看板 + 远程访问，独立项目）
- [ ] **v3.0** —— JAAOS 三引擎融合（Ruflo + Hermes Kanban + AgentTeams）

### 长期方向

- 领域自适应模式（科研 / 工程 / 学习 / 决策 / 创造）
- 全局自动读取记忆（PreToolUse hook）
- 团队配置热加载（运行中调整角色）
- 模型 A/B 测试（Haiku vs Sonnet reviewer 挑错率对比）

---

## 🌟 Star This Repo

如果卷卷团队救过你避免一次单 Agent 灾难，请⭐ star 这个仓库——帮助更多人发现它。

---

**由 🌀 [dxkjuanjuan](https://github.com/dxkjuanjuan) 制作**
