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

## 📁 项目结构

```
juanjuan-team/
├── SKILL.md                          # 主入口 + 11 阶段流程 + DAG + 自动触发
├── references/
│   ├── global-rules.md               # 10 条硬约束 + 4 模式（7 角色共享）
│   ├── role-leader.md                # 7 个角色完整 prompt
│   ├── role-convener.md              # 每个含: 身份 / 性格 / 工作流 /
│   ├── role-architect.md             #   协作关系 / 禁止事项 /
│   ├── role-frontend.md              #   输出格式 / 工具权限 /
│   ├── role-coder.md                 #   CLAUDE.md 一致性 / 模式表 /
│   ├── role-reviewer.md              #   错误处理
│   ├── role-docs-researcher.md
│   ├── decision-engine.md            # 对抗式辩论 + 加权评分
│   ├── state-machine.md              # 10 状态任务生命周期
│   ├── skill-allocation.md           # ★ 角色技能分配（SuperPower + ECC 按角色分配）
│   ├── agent-commands.md             # ★ Agent 命令规范（跨平台 Codex/Hermes 兼容）
│   ├── customization.md              # ★ 灵活配置指南（改 prompt/数量/理论）
│   └── backup-script.sh              # tar.gz + git bundle（可执行）
└── scripts/
    ├── swarm-spawn.sh                # 7 Agent spawn 文档
    └── backup-check.sh               # 备份触发条件检查（可执行）
```

★ = v1.1 新增

---

## 🔬 实战验证

这个 skill 在自己的设计上做了实战测试：

1. **设计阶段**：用三方 LLM 协作（ChatGPT 出理论、Claude 出实现、Gemini 出元提示词）
2. **自审**：spawn 3 个子 Agent 扮演 leader/architect/reviewer，发现 5 个 CRITICAL + 8 个 HIGH，全部修复
3. **Auto 模式验证**：跑了一个真实 bug 修复（kaoyan-english-app 缺失页面）：
   - 6 个页面 281 行写完（每个 < 65 行）
   - Reviewer 抓到 3 个 minor，0 critical
   - OWASP Top 10 全 N/A（用 JSX children 不用 `dangerouslySetInnerHTML`，规避 XSS）
   - build 通过、备份创建、记忆存档

---

## 🧠 哲学

> "不要优化成最快给出答案。要优化成给出最好的答案。"

单 Agent 平庸的答案，比不上：
**规划 → 专家分析 → 独立批评 → 修改 → 验证 → 交付**

这不是聊天机器人，是一个**模拟工程团队**——有角色分工、对抗式审查、记忆、持续改进。

---

## 📋 量化标准（Reviewer 必查清单）

- 测试覆盖率（核心路径）≥ 80%
- 单文件 < 500 行
- commit 信息无 `Co-Authored-By` AI 署名 trailer
- 前端遵循 `shadcn/ui` + `Ant Design`
- OWASP Top 10 逐条检查
- 无硬编码 secrets（20+ 模式黑名单）
- 代码风格：immutability、KISS、DRY、YAGNI

---

## 🛣️ Roadmap

- [x] v1.0 —— 7 Agent 团队 + 11 阶段流程 + 4 模式
- [ ] v1.1 —— JAAOS 集成（Ruflo + Hermes Kanban + AgentTeams）做可视化监控
- [ ] v1.2 —— Web UI（群聊 + 看板 + 远程访问）
- [ ] v2.0 —— 领域自适应模式（科研 / 工程 / 学习 / 决策 / 创造）

---

## 📜 License

[Personal Use Only](LICENSE) —— 个人使用免费（学习、个人项目、学术研究、个人开发者工作流）。**禁止商用**，如需商用请联系作者。详见 [LICENSE](LICENSE)。

## 🙏 致谢

本作品站在巨人的肩膀上。下列开源项目的工具、设计和理念让卷卷团队成为可能，特此致敬：

- **[SuperPower](https://github.com/obra/superpowers-marketplace)** —— brainstorming、TDD、systematic-debugging、writing-plans、verification-before-completion 等子 Agent 方法论已整合进我们的角色分配（`references/skill-allocation.md`）。`superpowers:brainstorming` skill 是 Phase 0 头脑风暴的主入口。
- **[Ruflo / Claude Flow](https://github.com/ruvnet/ruflo)** —— MCP 工具（`swarm_init`、`agent_spawn`、`memory_search`、`memory_store`、`hive-mind_consensus`）是驱动 7 人 Agent 团队的执行引擎。ruvLLM 自学习层作为差异化优势保留。
- **[ECC (Essential Claude Code) Rules](https://github.com/)** —— `code-review`、`security-review`、`build-fix`、`kimi-webbridge` 等 skills 按角色分配。`global-rules.md` 的 10 条硬约束对齐 ECC 的 coding-style、testing、performance、security 标准。

没有这些项目，卷卷团队不会存在。感谢这些社区的所有贡献者。

## 🤝 Contributing

见 [CONTRIBUTING.md](CONTRIBUTING.md)。欢迎 bug 报告和 PR。

## 🌟 Star This Repo

如果卷卷团队救过你避免一次单 Agent 灾难，请⭐ star 这个仓库——帮助更多人发现它。

---

**由 🌀 [dxkjuanjuan](https://github.com/dxkjuanjuan) 制作**
