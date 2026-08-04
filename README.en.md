# 🌀 Juanjuan Team

**The first adversarial-collaboration multi-agent Skill for Claude Code — built to fix single-agent cognitive tunneling.**

> Stop trusting one LLM to design, build, and review its own work. Juanjuan Team spawns 7 specialized agents that independently analyze, debate, and audit every deliverable — so errors get caught before they reach you.

[![License: Personal Use](https://img.shields.io/badge/License-Personal%20Use-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://claude.com/claude-code)
[![Status: v1.0](https://img.shields.io/badge/status-v1.0%20stable-brightgreen)](#)
[![Min Claude Code](https://img.shields.io/badge/Min%20Claude%20Code-2.0%2B-orange)](#)

🌐 **Languages:** [中文](README.md) | **English** | [日本語](README.ja.md) | [한국어](README.ko.md)

---

## 🎯 Why Juanjuan Team?

Every senior engineer has watched a single LLM spiral: it designs a flawed architecture, implements it, then "reviews" its own work and approves the same flaw. The bug ships. **Juanjuan Team exists to make this impossible.**

Built on **adversarial collaboration** — the same principle that makes human code review work — every meaningful decision is independently analyzed by 3+ agents who never see each other's opinions before submitting their own.

### ⚡ The 30-Second Pitch

| Single Agent | Juanjuan Team |
|-------------|---------------|
| Designs + implements + reviews alone | 7 agents split across design, implementation, and review |
| Approves its own mistakes (cognitive tunneling) | Reviewer is structurally forbidden from writing code/docs (no self-endorsement) |
| Forgets everything between sessions | Auto-stores lessons to Ruflo memory + auto-recalls on next project |
| No project isolation | Auto-creates dated project dirs + smart backup |
| One-shot decisions | Weighted decision engine (Tech 30% + Value 25% + Maintainability 20% + Security 15% + Cost 10%) |

---

## 🆚 How It Differs From Other Multi-Agent Frameworks

| Framework | Approach | Weakness | Juanjuan Team's Answer |
|-----------|---------|----------|------------------------|
| **CrewAI** | Role-based agents, sequential tasks | Roles can read each other's outputs → groupthink | **Independent review enforced**: reviewer cannot see other agents' opinions before submitting |
| **LangGraph** | Graph-based workflow | Focus on flow, not on adversarial thinking | **Debate protocol built-in**: Proposer → Critic → Optimizer → Judge |
| **AutoGen** | Conversational agents | All agents talk freely → chaos | **Single-window policy**: only Convener talks to user, 6 others coordinate internally |
| **OpenAI Swarm** | Lightweight handoffs | No memory, no audit | **Memory + state machine**: every task has lifecycle, every lesson is stored |
| **Claude Subagents** | One-off task delegation | No team coherence | **7-role team with character**: each agent has identity, prohibitions, error-handling |

### 🌟 Five Things Only Juanjuan Team Has

1. **Structural anti-self-endorsement** — the Reviewer is contractually forbidden from writing code OR documents. Even a "quick one-line fix" is rejected. Issues can only be flagged, never self-fixed.

2. **Adversarial Debate Protocol** — for every important decision, four roles are played by existing agents: **Proposer** (architect) → **Critic** (reviewer) → **Optimizer** (convener) → **Judge** (leader). No new agents needed.

3. **Weighted Decision Engine** — when 3 solutions conflict, we don't vote. We score: `Technical Feasibility × 30% + User Value × 25% + Maintainability × 20% + Security × 15% + Cost × 10%`. LEVEL A/B/C/D decides escalation.

4. **Smart Backup with Secrets Blacklist** — auto-backs up when `git diff > 200 lines` OR `files changed > 5`. Excludes 20+ secret patterns (`.env`, `id_rsa`, `.aws/credentials`, `*.keystore`, `*.kdbx`, etc.). Daily cap of 3 to prevent disk spam.

5. **Smart use of Claude Code built-in commands** — Claude Code's latest version changed `/review` and `/deep-reach` to require manual invocation (not disabled, just no longer auto-triggered). Our Reviewer agent proactively invokes these commands via `/`, and can also fall back to subagent alternatives when needed (`code-reviewer` subagent for `/review`, `memory_search` + `kimi-webbridge` for `/deep-reach`). On other platforms (Codex / Hermes / Gemini CLI), equivalent commands are used.

---

## 🏗️ Architecture

```
                    User (卷卷)
                       │
                  Convener (only dialog)
                       │
                    Leader
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   Architect       Reviewer    Docs-Researcher
   (Proposer)     (Critic)     (Memory)
                       │
              ┌────────┴────────┐
              │                 │
          Frontend            Coder
```

### 11-Phase Workflow

```
Phase 0  Brainstorm      Phase 6  Doc Review
Phase 1  Mode Select      Phase 7  Implementation (frontend + coder parallel)
Phase 2  Project Dir      Phase 8  Code Review (OWASP Top 10 + 80% coverage)
Phase 3  Propose A/B/C    Phase 9  Smart Backup (tar.gz + git bundle)
Phase 4  Adversarial Audit Phase 10  Store Memory
Phase 5  Spec Doc         Phase 11  Report
```

### 4 Execution Modes

| Mode | Behavior | Use When |
|------|---------|----------|
| **Safe** | Every phase audited + user confirms each step | Production, irreversible changes |
| **Normal** | Team only brainstorms, user audits everything | User wants full control |
| **Auto** | Team audits, escalates only hard choices | Daily recommended |
| **YOLO** | Full autonomy, hive-mind voting | Trusted team, fast output |

---

## 📦 Installation

### Option A: One-liner via gh CLI

```bash
gh repo clone dxkjuanjuan/juanjuan-team ~/.claude/skills/juanjuan-team
```

### Option B: Manual

```bash
git clone https://github.com/dxkjuanjuan/juanjuan-team.git ~/.claude/skills/juanjuan-team
chmod +x ~/.claude/skills/juanjuan-team/references/backup-script.sh
chmod +x ~/.claude/skills/juanjuan-team/scripts/*.sh
```

### Prerequisites

- **Claude Code 2.0+** (skill system)
- **Ruflo MCP server** configured (for `mcp__claude-flow__*` tools)
  ```bash
  claude mcp add claude-flow -- npx -y ruflo@latest mcp start
  ```
- **Bash + git** (for backup scripts)

### Verify Installation

Restart Claude Code, then in any conversation say:

```
用卷卷 skill
```

(or `juanjuan skill` / `用 juanjuan team`)

Convener will introduce itself and ask what you want to work on.

---

## 🤖 Supported Agent Platforms

Juanjuan Team is primarily designed for **Claude Code**, but can be adapted to other AI coding agents:

| Agent | How to Use |
|-------|-----------|
| **Claude Code** (primary) | Drop the skill into `~/.claude/skills/juanjuan-team/`. Use keywords like `juanjuan skill` to trigger. |
| **Codex CLI** | Copy `references/role-*.md` as system prompts in your Codex config. The 7-role prompts are model-agnostic. |
| **Gemini CLI** | Use `role-*.md` as system instructions in `.gemini/agent.json`. Replace `kimi-webbridge` skill with Gemini's browser tool. |
| **Cursor** | Add role prompts to `.cursorrules` or Cursor's agent config. Map `mcp__claude-flow__*` calls to your MCP setup. |
| **Cline** | Use the role prompts as `.clinerules`. Adapt MCP tool names if needed. |
| **Continue.dev** | Configure the 7 roles as custom agents in `config.json`. |

> **Note:** The skill's MCP tool calls (`mcp__claude-flow__*`) are Claude Code specific. For other agents, either (a) set up a parallel MCP server, or (b) replace with that agent's equivalent tool calls.

---

## 🚀 Quick Start

```
You: juanjuan skill

Convener: Hi! I'm your Convener. What would you like to work on?
          (docs-researcher is searching memory for related lessons...)

You: Fix the missing pages bug in my React project.

Convener: Got it. Based on complexity, I recommend Auto mode.
          Safe / Normal / Auto / YOLO?

You: Auto.

Convener: [Phase 2] Created ~/项目/2026-08-03-2230-fix-pages/
          [Phase 3] Architect proposed 3 solutions
          [Phase 4] Reviewer + Architect + Docs-Researcher audited independently
                   → Weighted score: Solution B = 82.75 (LEVEL B)
          [Phase 7] Coder implemented, build passed
          [Phase 8] Reviewer: pass (3 minor, no critical)
          [Phase 9] Backup created (29KB tar.gz + 29KB git bundle)
          [Phase 10] Memory stored for future projects
          [Phase 11] Done! 6 files, 281 lines, all under 65 lines each.
```

---

## 📁 Project Structure

```
juanjuan-team/
├── SKILL.md                          # Entry point + 11-Phase workflow + DAG
├── references/
│   ├── global-rules.md               # 10 hard constraints + 4 modes (shared by all 7 agents)
│   ├── role-leader.md                # 7 complete agent system prompts
│   ├── role-convener.md              # Each has: identity / personality /
│   ├── role-architect.md             #   workflow / topology / prohibitions /
│   ├── role-frontend.md              #   output schema / tool permissions /
│   ├── role-coder.md                 #   CLAUDE.md alignment / mode matrix /
│   ├── role-reviewer.md              #   error handling
│   ├── role-docs-researcher.md
│   ├── decision-engine.md            # Adversarial debate + weighted scoring
│   ├── state-machine.md              # 10-state task lifecycle
│   ├── skill-allocation.md           # ★ Role-skill allocation (SuperPower + ECC by role)
│   ├── agent-commands.md             # ★ Agent command spec (cross-platform Codex/Hermes)
│   ├── customization.md              # ★ Customization guide (change prompt/count/theory)
│   └── backup-script.sh              # tar.gz + git bundle (executable)
└── scripts/
    ├── swarm-spawn.sh                # 7-agent spawn documentation
    └── backup-check.sh               # Backup trigger check (executable)
```

---

## 🔬 Real-World Validation

This skill was battle-tested on its own design:

1. **Designed** with 3-way LLM collaboration (ChatGPT for theory, Claude for implementation, Gemini for meta-prompting)
2. **Self-audited** by 3 subagents playing leader/architect/reviewer roles — found 5 CRITICAL + 8 HIGH issues, all fixed
3. **Auto-mode validated** on a real bug fix (kaoyan-english-app missing pages):
   - 6 pages created in 281 lines (all <65 lines each)
   - Reviewer caught 3 minor issues, 0 critical
   - OWASP Top 10 all N/A (no XSS via `dangerouslySetInnerHTML`)
   - Build passed, backup created, memory stored

---

## 🧠 The Philosophy

> "Never optimize for producing the fastest answer. Optimize for producing the best possible answer."

A mediocre single-agent answer is inferior to:
**Planning → Expert Analysis → Independent Criticism → Revision → Validation → Final Delivery**

This is not a chatbot. It's a **simulated engineering team** with role separation, adversarial review, memory, and continuous improvement.

---

## 📋 Quantified Standards (Reviewer Checklist)

- Test coverage (core paths) ≥ 80%
- Single file < 500 lines
- No `Co-Authored-By` AI attribution trailers
- Frontend follows `shadcn/ui` + `Ant Design`
- OWASP Top 10 verified per code review
- No hardcoded secrets (20+ pattern blacklist)
- Code style: immutability, KISS, DRY, YAGNI

---

## 🛣️ Roadmap

- [x] v1.0 — 7-agent team + 11-Phase workflow + 4 modes
- [ ] v1.1 — JAAOS integration (Ruflo + Hermes Kanban + AgentTeams) for visual monitoring
- [ ] v1.2 — Web UI (chat room + Kanban board + remote access)
- [ ] v2.0 — Domain-adaptive modes (Research / Engineering / Learning / Decision / Creative)

---

## 📜 License

[Personal Use Only](LICENSE) — free for personal use (learning, personal projects, academic research, individual developer workflows). Commercial use is prohibited without written permission. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgements

This project stands on the shoulders of giants. We respectfully acknowledge the following open-source projects whose tools, designs, and ideas made Juanjuan Team possible:

- **[SuperPower](https://github.com/obra/superpowers-marketplace)** — The brainstorming, TDD, systematic-debugging, writing-plans, verification-before-completion, and other subagent methodologies are integrated into our agent role allocation (`references/skill-allocation.md`). The `superpowers:brainstorming` skill is the main entry point for Phase 0.
- **[Ruflo / Claude Flow](https://github.com/ruvnet/ruflo)** — The MCP tools (`swarm_init`, `agent_spawn`, `memory_search`, `memory_store`, `hive-mind_consensus`) are the execution engine powering our 7-agent team. The ruvLLM self-learning layer is preserved as a differentiation advantage.
- **[ECC (Essential Claude Code) Rules](https://github.com/)** — The `code-review`, `security-review`, `build-fix`, `kimi-webbridge`, and other skills are allocated per role. The 10 hard constraints in `global-rules.md` are aligned with ECC's coding-style, testing, performance, security standards.

Without these projects, Juanjuan Team would not exist. Thank you to all the contributors of these communities.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports and PRs welcome.

## 🌟 Star This Repo

If Juanjuan Team saved you from a single-agent disaster, please ⭐ star this repo — it helps others discover it.

---

**Made with 🌀 by [dxkjuanjuan](https://github.com/dxkjuanjuan)**
