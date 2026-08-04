# Juanjuan Team Domain Checklists

**用途**：借鉴 agent-review-panel 的 9 auto-detected signal groups，给 Reviewer 提供系统化的审查维度。

---

## 一、9 个自动检测信号组

Reviewer 在 Phase 8 代码审查时，自动检测以下 9 个信号组：

| # | 信号组 | 检测内容 | 严重度 |
|---|--------|---------|--------|
| 1 | **Correctness** | 逻辑错误、边界条件、空值、类型不匹配 | critical |
| 2 | **Security** | OWASP 2021 A01-A10、硬编码 secrets、注入点 | critical |
| 3 | **Performance** | N+1 查询、不必要的重渲染、内存泄漏、大循环 | major |
| 4 | **Maintainability** | 文件 >500 行、重复代码、过度抽象、深嵌套 | major |
| 5 | **Accessibility** | 缺 aria-label、无键盘导航、对比度不足、缺 alt | major |
| 6 | **Error Handling** | 未捕获异常、静默失败、错误信息泄露、无降级 | major |
| 7 | **Test Coverage** | 覆盖率 <80%、无边界测试、无错误路径测试 | major |
| 8 | **API Design** | 无输入验证、无错误响应格式、无版本控制、无 rate limit | minor |
| 9 | **Documentation** | 缺 README、无 API 文档、注释过时、无示例 | minor |

---

## 二、Domain-specific Checklists

### 前端（Frontend）

- [ ] WCAG 2.1 AA 合规（对比度 ≥ 4.5:1）
- [ ] 键盘可导航（Tab 顺序合理）
- [ ] 响应式（320/768/1024/1440 断点）
- [ ] 无 layout shift（CLS < 0.1）
- [ ] shadcn/ui + Ant Design 规范
- [ ] 加载态/空状态/错误态三态覆盖

### 后端（Backend）

- [ ] 输入验证（schema-based，Zod/Joi）
- [ ] 错误处理（try-catch + 统一错误格式）
- [ ] SQL 注入防护（参数化查询）
- [ ] CSRF 防护
- [ ] Rate limiting
- [ ] 无硬编码 secrets（用环境变量）
- [ ] 日志不泄露敏感信息

### 安全（Security）

- [ ] OWASP 2021 A01 Broken Access Control
- [ ] OWASP 2021 A02 Cryptographic Failures
- [ ] OWASP 2021 A03 Injection
- [ ] OWASP 2021 A04 Insecure Design
- [ ] OWASP 2021 A05 Security Misconfiguration
- [ ] OWASP 2021 A06 Vulnerable Components
- [ ] OWASP 2021 A07 Auth Failures
- [ ] OWASP 2021 A08 Software & Data Integrity
- [ ] OWASP 2021 A09 Security Logging
- [ ] OWASP 2021 A10 SSRF

### 科研（Research）

- [ ] 引用真实性（不编造参考文献）
- [ ] 数据可复现（实验有 seed/参数记录）
- [ ] 统计显著性（p < 0.05 标注）
- [ ] 局限性声明（明确缺陷）
- [ ] 与 baseline 对比（不只说"更好"）

---

## 三、Anti-Groupthink 机制

借鉴 agent-review-panel：

1. **独立产出**：每个 Reviewer 先独立审查，不看其他 Reviewer 的输出
2. **辩论阶段**：独立产出后进入辩论，必须攻击想法而非人
3. **Judge 裁决**：Leader 基于**证据**裁决，不是基于多数意见
4. **升级机制**：Reviewer 发现自己错了时必须声明"我升级此项到 IMPORTANT"

---

## 四、报告输出格式

### 默认：Markdown 报告

Phase 8 代码审查默认输出 Markdown 报告（`review_report.md`），包含：
- 执行摘要
- 9 信号组逐条结果
- 共识与分歧
- Leader 裁决
- 行动项

### 可选：HTML 交互式看板

**仅当用户明确要求时**才生成 HTML 报告（`review_report.html`），包含：
- 可展开的 issue 卡片
- 图表（信号组分布、严重度统计）
- Agent 面板画廊

> ⚠️ HTML 报告会消耗额外 token，默认不生成。用户说「生成 HTML 报告」/「出个看板」时才生成。
