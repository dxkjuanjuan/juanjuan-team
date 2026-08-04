# Juanjuan Team Agent 命令规范

**用途**：每个角色可用什么命令、何时调用、跨平台（Codex / Humus / Gemini CLI）等价方案。

> **背景**：Claude Code 最新版把 `/review` 和 `/deep-reach` 等命令改成**必须手动调用**（不是禁用，是 Agent 需要主动用 `/` 前缀调用）。本文件明确每个角色在什么场景调什么命令。

---

## 一、命令调用基本原则

### 1.1 Agent 必须主动调用

最新 Claude Code 把 `/review`、`/security-review`、`/deep-reach` 等内置命令改成「Agent 主动调用才生效」。Agent 不能等系统自动跑，必须自己判断场景后用 `/命令` 调用。

### 1.2 跨平台等价

Codex / Humus / Gemini CLI / Cursor / Cline 没有 Claude Code 的内置命令时，用该平台的等价命令完成相同任务。本文件每个命令都给出跨平台映射。

### 1.3 主 Agent + 子 Agent 双轨

- **主 Agent**（7 个角色之一）算力最强（Opus 4.7），做决策和最终产出
- **子 Agent**（通过 `subagent_type` 或 skill 调用）做辅助任务
- 主 Agent 必须自己也参与，不能把任务全甩给子 Agent

---

## 二、按场景调用命令

### 场景 1：代码审查

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Reviewer | Phase 8 代码审查 | `/review` 或 `/security-review` 或 `/code-review` |
| Coder/Frontend | 自查后再交 Reviewer | `superpowers:requesting-code-review` |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex review` 或调 `code-reviewer` subagent |
| Gemini CLI | `gemini review` 或在 agent.json 配 reviewer 子 Agent |
| Cursor | Cursor 的 AI Review 功能 |
| Cline | `.clinerules` 里写审查规则 |
| Humus | 该平台的审查工具，或人工 spawn reviewer subagent |

### 场景 2：深度搜索/资料查找

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Docs-Researcher | Phase 0/5 查记忆库 + 外部资料 | `memory_search` (MCP) + `kimi-webbridge` skill（禁用 WebSearch） |
| Architect | Phase 4 查技术资料 | 转 Docs-Researcher 处理 |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex search` 或 `docs-lookup` subagent |
| Gemini CLI | Gemini 的搜索工具 + `docs-lookup` |
| Cursor | Cursor 的 @codebase 搜索 |
| Cline | 配置 `docs-lookup` subagent |
| Humus | 该平台的搜索工具 |

### 场景 3：TDD 测试驱动

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Coder | Phase 7 写代码前 | `superpowers:test-driven-development` 或 `/tdd` |
| Coder | 写完后跑测试 | `/test` 或 `pnpm test` |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex test` 或调 `tdd-guide` subagent |
| Gemini CLI | 在 agent.json 配 tdd-guide 子 Agent |
| Cursor | Cursor 的 AI Test 功能 |
| Cline | 配置 `tdd-guide` subagent |
| Humus | 该平台的测试工具 |

### 场景 4：头脑风暴（Phase 0）

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Convener | Phase 0 启动 | `superpowers:brainstorming`（juanjuan-team 完全调用，不自己写简版） |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex brainstorm` 或人工用 superpowers 提示词 |
| Gemini CLI | 在 agent.json 配 brainstorming 子 Agent |
| Cursor | 手动调 brainstorming skill |
| Cline | 配置 `brainstorming` subagent |
| Humus | 该平台的 brainstorming 工具 |

### 场景 5：写实施计划

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Convener | Phase 5 写 spec/计划 | `superpowers:writing-plans` 或 `/plan` |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex plan` 或调 `Plan` subagent |
| Gemini CLI | 在 agent.json 配 Plan 子 Agent |
| Cursor | Cursor 的 AI Plan 功能 |
| Cline | 配置 `Plan` subagent |
| Humus | 该平台的计划工具 |

### 场景 6：build 错误修复

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Coder/Frontend | build 失败 | `/build-fix`（ECC）或调 `build-error-resolver` subagent |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex build fix` 或调 build-error-resolver |
| Gemini CLI | 在 agent.json 配 build-error-resolver |
| Cursor | Cursor 的 AI Build Fix 功能 |
| Cline | 配置 `build-error-resolver` subagent |
| Humus | 该平台的 build 修复工具 |

### 场景 7：完成前验证

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| 所有角色 | 交付前 | `superpowers:verification-before-completion` 或 `/verify:check` |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex verify` 或人工跑测试 |
| Gemini CLI | 在 agent.json 配 verify 子 Agent |
| Cursor | Cursor 的 AI Verify 功能 |
| Cline | 配置 `verification-quality` subagent |
| Humus | 该平台的验证工具 |

### 场景 8：项目初始化

| 角色 | 触发条件 | 命令 |
|------|---------|------|
| Convener | Phase 2 建项目目录 | `/init`（ECC）+ juanjuan-team 的 backup-script.sh |

**跨平台等价**：
| 平台 | 等价命令 |
|------|---------|
| Codex CLI | `codex init` |
| Gemini CLI | `gemini init` |
| Cursor | 手动建目录 + git init |
| Cline | 手动建目录 + git init |
| Humus | 该平台的 init 工具 |

---

## 三、角色可调命令清单（汇总）

### Leader
- `superpowers:dispatching-parallel-agents` —— 并行调度
- `superpowers:executing-plans` —— 执行计划
- `/verify:check` —— 完成前验证

### Convener
- **`superpowers:brainstorming`** —— Phase 0 主入口（必调）
- `superpowers:writing-plans` —— 写计划
- `superpowers:verification-before-completion` —— 完成前验证
- `/init` —— 项目初始化
- `/plan` —— 写计划（ECC）

### Architect
- `superpowers:writing-plans` —— 写技术方案
- `/plan` —— 写计划（ECC）
- `superpowers:verification-before-completion` —— 完成前验证

### Frontend
- `superpowers:test-driven-development` —— TDD
- `superpowers:systematic-debugging` —— 调试
- `/build-fix` —— build 错误（ECC）
- `/react-build` —— React build 修复（ECC，按语言）

### Coder
- `superpowers:test-driven-development` —— TDD
- `superpowers:systematic-debugging` —— 调试
- `/build-fix` —— build 错误（ECC）
- `/test-coverage` —— 测试覆盖率（ECC）
- `superpowers:verification-before-completion` —— 完成前验证

### Reviewer
- **`/review`** —— 代码审查（必调）
- **`/security-review`** —— 安全审查（必调）
- `/code-review` —— ECC 代码审查 skill
- `superpowers:requesting-code-review` —— 主动请求审查
- `superpowers:verification-quality` —— 质量验证

### Docs-Researcher
- `superpowers:writing-skills` —— 写 skill 文档
- `superpowers:writing-plans` —— 写计划
- `kimi-webbridge` skill —— 浏览器自动化（禁用 WebSearch）
- `mcp__claude-flow__memory_search` —— 查记忆库
- `mcp__claude-flow__memory_store` —— 存记忆

---

## 四、何时必须调用命令

### 硬性规则（必须调）

1. **Phase 0 头脑风暴** → Convener 必须调 `superpowers:brainstorming`
2. **Phase 8 代码审查** → Reviewer 必须调 `/review` + `/security-review`
3. **Phase 9 备份前** → Convener 必须跑 `backup-check.sh` 验证触发条件
4. **Phase 10 存记忆** → Docs-Researcher 必须调 `memory_store`

### 软性规则（按需调）

1. **build 失败** → Coder/Frontend 调 `/build-fix`
2. **测试覆盖率不足** → Coder 调 `/test-coverage`
3. **跨语言审查** → Reviewer 调对应语言专项（如 `/python-review`）
4. **资料查找** → Docs-Researcher 调 `kimi-webbridge`（禁用 WebSearch）

---

## 五、跨平台等价速查表

| Claude Code | Codex | Gemini CLI | Cursor | Cline | Humus |
|------------|------|-----------|--------|-------|-------|
| `/review` | `codex review` | agent.json 配 reviewer | AI Review | `.clinerules` | 平台工具 |
| `/security-review` | `codex security` | agent.json 配 security | AI Security | `.clinerules` | 平台工具 |
| `/deep-reach` | `codex search` | Gemini search | @codebase | `docs-lookup` | 平台工具 |
| `/init` | `codex init` | `gemini init` | 手动 | 手动 | 平台工具 |
| `/plan` | `codex plan` | agent.json 配 Plan | AI Plan | `Plan` | 平台工具 |
| `/tdd` | `codex test` | agent.json 配 tdd | AI Test | `tdd-guide` | 平台工具 |
| `/build-fix` | `codex build fix` | agent.json 配 build-fix | AI Build Fix | `build-error-resolver` | 平台工具 |
| `superpowers:*` | 人工提示词 | 人工提示词 | 人工提示词 | 人工提示词 | 人工提示词 |

> **注意**：其他平台没有 SuperPower 子 Agent 时，把 `references/role-*.md` 作为系统提示词人工加载，用该平台的子 Agent 机制模拟。
