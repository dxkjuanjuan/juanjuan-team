# Juanjuan Team 角色技能分配矩阵

**用途**：按角色分配 SuperPower 子 Agent + ECC skills。每个角色可开自己的子 Agent 团队做子任务，但主 Agent 必须自己也参与（主 Agent 算力最强，子 Agent 只做辅助）。

---

## 一、技能来源

| 来源 | 类型 | 说明 |
|------|------|------|
| **SuperPower** | 子 Agent（subagent_type） | 通过 `Agent({subagent_type: ...})` 调用 |
| **ECC** | skills | 通过 `Skill({skill: ...})` 调用 |
| **juanjuan-team 自有** | 7 个角色 + 流程 | 通过 MCP 工具 + Agent 派发调用 |

---

## 二、通用 skills（所有角色共享）

| Skill | 来源 | 用途 |
|-------|------|------|
| `using-superpowers` | SuperPower | 所有 skill 调用前的元规则 |
| `using-skills` | SuperPower | 如何发现和使用 skills |
| `kimi-webbridge` | ECC | 浏览器自动化（替代 WebSearch，卷卷 CLAUDE.md 约束） |
| `planning-with-files-zh` | ECC | 任务规划文件持久化 |
| `verification-quality` | ECC | 质量验证 + 真相评分 |

---

## 三、按角色分配

### 1. Leader（调控者）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `dispatching-parallel-agents` | 并行调度多个 Agent |
| `executing-plans` | 执行实施计划 |
| `swarm-orchestration` | 群体编排 |

**可开的子 Agent 团队**：
- `hierarchical-coordinator` —— 层级协调
- `mesh-coordinator` —— 网状协调
- `adaptive-coordinator` —— 自适应协调

**子 Agent 使用规则**：Leader 遇到多 Agent 协调复杂场景时，开 coordinator 子 Agent 辅助调度，但 Leader 自己必须做最终决策。

---

### 2. Convener（主对接 + 总审核）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `brainstorming` | **Phase 0 头脑风暴主入口**（替代 juanjuan-team 自己写简版） |
| `writing-plans` | 写实施计划 |
| `verification-before-completion` | 完成前验证 |

**可开的子 Agent 团队**：
- `general-purpose` —— 通用研究、信息收集
- `Plan` —— 软件架构师设计实施计划
- `code-reviewer` —— 通用代码审查（不替代 reviewer 角色，仅辅助 convener 总审）

**子 Agent 使用规则**：Convener 在 Phase 0 必须调 `superpowers:brainstorming` skill；其他场景可开子 Agent 做信息整理，但最终对话只能由 Convener 自己跟卷卷进行。

---

### 3. Architect（架构师）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `architecture` | SuperPower 架构设计 |
| `writing-plans` | 写技术方案 |
| `design-system` | ECC 设计系统（前端架构时） |
| `sparc-methodology` | SPARC 方法论 |

**可开的子 Agent 团队**：
- `architect` —— SuperPower 架构师子 Agent
- `system-architect` —— 系统架构设计
- `code-architect` —— 代码架构分析
- `code-explorer` —— 代码库探索

**子 Agent 使用规则**：Architect 设计复杂系统时可开 `architect` / `system-architect` 子 Agent 辅助出方案，但最终架构决策必须 Architect 自己拍板。

---

### 4. Frontend（前端工程师）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `ui-styling` | shadcn/ui + Tailwind |
| `ui-ux-pro-max` | UI/UX 设计智能 |
| `ui-forge` | 5-stage UI 设计锻造 |
| `awesome-design-md` | 73 个品牌 DESIGN.md |
| `frontend-design` | 视觉规范 |

**可开的子 Agent 团队**：
- `react-reviewer` —— React 代码审查
- `react-build-resolver` —— React build 错误修复
- `flutter-reviewer` / `vue-reviewer` 等其他框架（按需）

**子 Agent 使用规则**：Frontend 写代码前可开 `code-explorer` 探索现有组件；写完后可开 `react-reviewer` 做自查（但正式审查仍由 reviewer 角色做）。

---

### 5. Coder（后端工程师）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `test-driven-development` | TDD 工作流 |
| `systematic-debugging` | 系统化调试 |
| `verification-before-completion` | 完成前验证 |
| `planning-with-files-zh` | 任务规划持久化 |

**按语言可加的 skills**：
| 语言 | 可用子 Agent |
|------|------------|
| TypeScript | `typescript-reviewer`, `react-build-resolver` |
| Python | `python-reviewer`, `django-build-resolver`, `fastapi-reviewer` |
| Go | `go-reviewer`, `go-build-resolver` |
| Rust | `rust-reviewer`, `rust-build-resolver` |
| Java | `java-reviewer`, `java-build-resolver` |
| C++ | `cpp-reviewer`, `cpp-build-resolver` |

**可开的子 Agent 团队**：
- `tdd-guide` —— TDD 强制执行
- `build-error-resolver` —— build 错误修复
- `silent-failure-hunter` —— 静默失败捕获

**子 Agent 使用规则**：Coder 写代码遇 build 错误可开 `build-error-resolver`；写测试可开 `tdd-guide`；但代码必须 Coder 自己写，子 Agent 只做诊断和建议。

---

### 6. Reviewer（安全审查 + 代码/文档审查）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `verification-before-completion` | 完成前验证 |
| `verification-quality` | 质量验证 + 真相评分 |
| `systematic-debugging` | 系统化找 bug |
| `requesting-code-review` | 主动请求代码审查 |

**可开的子 Agent 团队**（按语言自动选）：
- `code-reviewer` —— 通用代码审查
- `security-reviewer` —— 安全审查专家
- `typescript-reviewer` / `python-reviewer` / `go-reviewer` / `rust-reviewer` 等语言专项
- `silent-failure-hunter` —— 静默失败捕获
- `comment-analyzer` —— 注释分析
- `type-design-analyzer` —— 类型设计分析

**可调用的 Claude Code 命令**（需主动 `/` 前缀调用，不是自动触发）：
- `superpowers:requesting-code-review` —— SuperPower 主动请求审查
- spawn `code-reviewer` subagent —— 通用代码审查 fallback
- spawn `security-reviewer` subagent —— 安全审查 fallback
- spawn `silent-failure-hunter` subagent —— 静默失败捕获

> ⚠️ `/review` 和 `/security-review` 在最新 Claude Code 改成「需主动 `/` 调用」，Reviewer 可主动调；若调用失败则 spawn subagent 作为 fallback（详见 SKILL.md §十三）

**子 Agent 使用规则**：Reviewer 在 Phase 8 代码审查时，可同时开多个语言专项子 Agent（如 `typescript-reviewer` + `security-reviewer` + `silent-failure-hunter`）并行审查，但 Reviewer 自己必须汇总所有意见，做最终 verdict。

**关键约束**：Reviewer 不能让子 Agent 替自己做最终 verdict——子 Agent 只提供 finding，Reviewer 自己定 pass/reject。

---

### 7. Docs-Researcher（文档 + 资料查找 + 浏览器调试）

**主 Agent skills**：
| Skill | 用途 |
|-------|------|
| `writing-skills` | SuperPower 写 skill 文档 |
| `writing-plans` | 写实施计划 |
| `kimi-webbridge` | 浏览器自动化（替代 WebSearch） |
| `planning-with-files-zh` | 任务规划持久化 |
| `agentdb-memory-patterns` | 记忆库模式 |
| `agentdb-vector-search` | 向量搜索 |

**可开的子 Agent 团队**：
- `docs-lookup` —— 用 Context7 MCP 查库文档
- `general-purpose` —— 通用研究
- `doc-updater` —— 文档更新
- `api-docs` —— OpenAPI/Swagger 文档

**子 Agent 使用规则**：Docs-Researcher 查资料时可开 `docs-lookup` + `general-purpose` 并行查；写 spec 时可开 `doc-updater` 辅助。但最终文档必须 Docs-Researcher 自己写。

**关键约束**：不审自己写的文档（避免自我背书），文档审查交给 Reviewer。

---

## 四、子 Agent 调用通用规则

### 4.1 主 Agent 必须参与

主 Agent 算力最强（Opus 4.7），子 Agent 只做辅助。所有最终产出必须由主 Agent 完成：

- ✅ 主 Agent 派子 Agent 做诊断/探索/查找
- ✅ 主 Agent 汇总子 Agent 的发现
- ✅ 主 Agent 自己做最终决策和产出
- ❌ 主 Agent 不能让子 Agent 替自己做最终 verdict
- ❌ 主 Agent 不能完全把任务甩给子 Agent

### 4.2 子 Agent 并行调度

多个独立子任务可并行开子 Agent：

```
Reviewer 审代码时:
  ├─ typescript-reviewer (并行)
  ├─ security-reviewer (并行)
  └─ silent-failure-hunter (并行)
→ Reviewer 汇总三方 finding，自己做 verdict
```

### 4.3 子 Agent 失败处理

子 Agent 失败时：
1. 主 Agent 重试一次（换更明确的任务描述）
2. 仍失败则主 Agent 自己接管该子任务
3. 上报 Convener/Leader

---

## 五、跨平台兼容（Codex / Humus / Gemini CLI 等）

其他 Agent 平台没有 Claude Code 的子 Agent / skill 系统时：

| Claude Code 概念 | Codex / Humus 等价方案 |
|-----------------|----------------------|
| `Agent({subagent_type: ...})` | 该平台的子 Agent / Tool 调用机制 |
| `Skill({skill: ...})` | 该平台的 skill / 指令加载机制 |
| `/review`, `/security-review` 命令 | 该平台的等价审查工具 |
| `mcp__claude-flow__*` MCP 工具 | 该平台配置对应 MCP 服务器 |

详细命令映射见 `agent-commands.md`。
