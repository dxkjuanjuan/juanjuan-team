# Juanjuan Team Lite 模式

**用途**：单文件任务走精简流程，避免 11 Phase 过重。

---

## 一、Lite 模式触发条件

同时满足：
1. 单文件任务（如写一个脚本、修一个 bug）
2. 不跨模块
3. 无架构影响
4. 无新功能（只是修 bug 或写小工具）

**不触发 Lite（走全流程）**：
- 多文件 / 跨模块 / 架构影响 / 新功能 / 不确定

---

## 二、Lite 流程（6 Phase）

```
[Phase 0] 头脑风暴（调 superpowers:brainstorming）
  ↓
[Phase 1] 模式选择（AskUserQuestion）
  ↓
[Phase 3] 方案生成（Convener + Architect，简化为 2 方案）
  ↓
[Phase 7] 实施（Coder 单独，无 frontend）
  ↓
[Phase 8] 代码审查（Reviewer，简化为只查 OWASP + 80% 覆盖率）
  ↓
[Phase 11] 汇报归档
```

**跳过**：Phase 0.5 / 2 / 4 / 5 / 6 / 9 / 10

---

## 三、Lite 模式 vs 全流程对比

| 维度 | Lite | 全流程 |
|------|------|--------|
| Phase 数 | 6 | 11 + 0.5 |
| 三方审核 | 无 | Phase 4 有 |
| 智能备份 | 无（用户自己 commit） | Phase 9 事件驱动 |
| 存记忆 | 无 | Phase 10 存 |
| 设计文档 | 无 | Phase 5 写 spec |
| 适用场景 | 单文件 bug 修复 / 小脚本 | 多文件 / 新功能 / 架构改动 |

---

## 四、如何判断走 Lite 还是全流程

Convener 在 Phase 0 头脑风暴时判断：

```
if (单文件 && 不跨模块 && 无架构影响) {
  建议 Lite 模式
  用 AskUserQuestion 让卷卷确认
} else {
  走全流程（11 Phase）
}
```

卷卷也可显式说「用 Lite」或「走全流程」覆盖判断。

---

## 五、Lite 模式的权衡

**优点**：
- 快（6 Phase vs 11 Phase）
- 省 token（无三方审核、无备份、无记忆存档）
- 适合小任务

**缺点**：
- 无三方对抗审核（单 Agent 可能出错）
- 无备份（用户自己 commit）
- 无记忆存档（下次类似任务查不到经验）

**建议**：重要任务即使单文件也走全流程，Lite 只用于低风险的快速任务。
