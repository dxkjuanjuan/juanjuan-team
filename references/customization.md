# Juanjuan Team 灵活配置指南

**核心原则**：7 个 Agent + 11 阶段 + 4 模式只是卷卷的默认配置，**不是唯一选择**。其他人可以按自己的偏好改 prompt、改 Agent 个数、改理论框架。

---

## 一、可改什么

| 可改项 | 怎么改 | 影响范围 |
|--------|--------|---------|
| Agent prompt | 改 `references/role-*.md` | 该角色行为 |
| Agent 个数 | 加/减 `role-*.md` + 改 SKILL.md 团队表 | 团队结构 |
| Agent 角色 | 删掉某个角色或加新角色 | 团队分工 |
| 11 阶段流程 | 改 SKILL.md 的工作流 | 任务执行顺序 |
| 4 模式 | 改 global-rules.md 的模式定义 | 模式行为 |
| 决策权重 | 改 decision-engine.md 的加权公式 | 方案选择逻辑 |
| 备份触发 | 改 backup-script.sh 的阈值 | 备份频率 |
| 记忆格式 | 改 SKILL.md 的记忆 YAML schema | 记忆库结构 |

---

## 二、改 Agent prompt

### 2.1 改单个角色性格

直接编辑 `references/role-<角色>.md`，例如让 Architect 更激进：

```markdown
## 2. 性格特质
- 激进，倾向选新技术而非稳定技术
- 拒绝过度设计但拥抱合理设计
- ...（其他你想要的性格）
```

### 2.2 改全局约束

改 `references/global-rules.md` 的 10 条硬约束。例如改语言：

```markdown
1. **语言**：全程使用英文交流（原来是中文）。
```

### 2.3 注入个人偏好

在 `references/global-rules.md` 加你自己的 CLAUDE.md 约束：

```markdown
11. **个人偏好**：称呼用户为「<你的昵称>」。
12. **代码风格**：你的个人编码规范。
13. ...（其他你的偏好）
```

---

## 三、改 Agent 个数

### 3.1 加新角色

**Step 1**：建 `references/role-<新角色>.md`，按 10 节模板写：

```markdown
# <新角色> —— <定位>

> **注入方式**：本文件拼在 `global-rules.md` 之后。

## 1. 身份与角色定位
你是 juanjuan-team 的 <新角色>，负责 <职责>。

## 2. 性格特质
- ...

## 3. 工作流程（按 Phase）
- Phase X: <做什么>

## 4. 协作关系
- 上级: <谁>
- 协作: <谁>

## 5. 禁止事项
1. 不...

## 6. 输出格式
{...}

## 7. 工具与权限
- 可调: ...
- 不可调: ...

## 8. 与卷卷 CLAUDE.md 一致性
...

## 9. 模式行为表
| 模式 | 行为 |

## 10. 错误处理
...
```

**Step 2**：改 SKILL.md 的团队配置表，加一行。

**Step 3**：改 `scripts/swarm-spawn.sh`，加 spawn 该角色。

**Step 4**：改 `skill-allocation.md`，给新角色分配 skills。

### 3.2 删角色

直接删 `role-<角色>.md`，从 SKILL.md 团队表和 swarm-spawn.sh 移除引用。

### 3.3 常见改法示例

**改成 5 人精简团队**（去掉 frontend + coder 合并为 coder，去掉 docs-researcher 让 convener 兼）：
- leader / convener / architect / coder / reviewer

**改成 10 人大团队**（加 tester / devops / pm / qa）：
- leader / convener / architect / frontend / coder / reviewer / docs-researcher / tester / devops / pm / qa

---

## 四、改理论框架

### 4.1 改决策引擎

`references/decision-engine.md` 现在是：
```
技术可行性 × 30% + 用户价值 × 25% + 可维护性 × 20% + 安全性 × 15% + 成本效率 × 10%
```

你可以改成：
```
创新性 × 40% + 实现速度 × 30% + 用户价值 × 30%
```

或者改成纯投票制（删掉加权评分，全部 hive-mind 投票）。

### 4.2 改对抗式辩论协议

现在 4 角色：Proposer / Critic / Optimizer / Judge。你可以：
- 加 `Skeptic`（怀疑论者，专门质疑前提假设）
- 删 `Optimizer`（不让优化者介入，保持方案纯粹）
- 改成 6 角色辩论（如 Oxford-style debate）

### 4.3 改状态机

`references/state-machine.md` 现在是 10 状态。你可以：
- 简化为 5 状态（CREATED / DOING / REVIEW / DONE / CANCELLED）
- 加 `BLOCKED` / `PAUSED` 状态
- 加回退路径

### 4.4 改模式定义

`references/global-rules.md` 现在是 Safe/Manual/Auto/YOLO。你可以：
- 加 `Stealth`（静默模式，不汇报中间过程）
- 加 `Pair`（双 Agent 配对模式）
- 删 `YOLO`（不允许全自动）

---

## 五、改备份机制

### 5.1 改触发阈值

`references/backup-script.sh` 现在是：
- git diff > 200 行
- 文件改动 > 5 个
- 每日 3 次上限

改成：
```bash
# 在 backup-check.sh 里改
if [ "$DIFF_LINES" -gt 500 ]; then  # 改成 500
...
elif [ "$CHANGED_FILES" -gt 10 ]; then  # 改成 10
```

### 5.2 改 secrets 黑名单

`references/backup-script.sh` 的 `SECRET_PATTERNS` 数组，加你的：
```bash
SECRET_PATTERNS=(
    ".env"
    # ... 原有
    "my-custom-secret-file"  # 加你的
    "*.myext"                # 加你的扩展名
)
```

### 5.3 改备份位置

改 SKILL.md 的 §6 备份位置，或改 backup-script.sh 的 `BACKUP_DIR`：
```bash
BACKUP_DIR="$PROJECT_DIR/.backups"
# 改成：
BACKUP_DIR="/mnt/backup/juanjuan-team"
```

---

## 六、改记忆格式

### 6.1 改记忆字段

SKILL.md 的 Phase 10 记忆 YAML schema：
```yaml
key: <项目目录名>
namespace: project
value: |
  任务简述: ...
  最终方案: ...
  踩坑: ...
  团队配置: ...
  模式选择: ...
  项目路径: ...
```

加字段：
```yaml
  甲方反馈: ...        # 加这个
  性能指标: ...        # 加这个
  复用价值: 高/中/低  # 加这个
```

### 6.2 改记忆库

ruflo memory 是默认后端，你可以改成：
- mem0（用 [[agent-self-evolution]] 的 mem0 集成）
- Neo4j 知识图谱（用 [[agent-self-evolution]] 的 Neo4j 自画像）
- 自建 SQLite + 向量索引

---

## 七、改触发关键词

SKILL.md 现在的触发词：
- `juanjuan skill` / `juanjuan skill`
- `用卷卷 skill`
- `用自己的 skills`
- `用 juanjuan team`
- `上 ruflo team`

改成你的：
```markdown
## 一、触发关键词
- `<你的关键词>`
- ...
```

---

## 八、配置示例

### 8.1 团队 A：科研论文团队

7 人改成：
- leader / convener / research-lead / writer / reviewer / editor / citation-checker

理论改成：Research Mode（参考 JAIT v1.0 Part 4）

### 8.2 团队 B：创业小团队

5 人精简：
- leader / convener / architect / coder / reviewer

模式删 YOLO（创业风险高，不允许全自动）。

### 8.3 团队 C：学习辅导团队

4 人：
- leader / convener / teacher / reviewer

加 Learning Mode（参考 JAIT v1.0 Part 4）。

---

## 九、配置文件版本管理

建议把你的配置 fork 一份：
```bash
gh repo clone dxkjuanjuan/juanjuan-team my-juanjuan-team
cd my-juanjuan-team
git checkout -b my-config
# 改你想要的
git push origin my-config
```

这样你可以：
- 跟 upstream 同步最新改动
- 保留自己的配置分支
- 随时切回默认配置

---

## 十、配置反模式（别这么改）

### 10.1 别删 Reviewer

Reviewer 是对抗式协作的核心。删了 Reviewer，juanjuan-team 就退化成 CrewAI 了。

### 10.2 别让 Reviewer 写代码

即使你加了一个"全能 Agent"，Reviewer 也必须保持"只审不写"。否则自我背书会毁掉整个系统。

### 10.3 别让 Convener 不对话

Convener 是唯一对外窗口。如果你让多个 Agent 都跟用户对话，会混乱。

### 10.4 别删 Phase 0 头脑风暴

Phase 0 是需求澄清的关键。即使你用 Auto/YOLO 模式，也得先头脑风暴。

### 10.5 别删智能备份

备份是回溯的最后保障。你可以改阈值，但别删机制。

---

## 十一、贡献你的配置

如果你改出了好用的配置，欢迎 PR：

1. Fork 仓库
2. 建分支：`config-<你的场景>`（如 `config-research-team`）
3. 改文件 + 在 README 里加你的配置说明
4. 开 PR，标题写 `[Config] <场景>`

我们会把优秀的配置 merge 到 `examples/` 目录，让更多人用上。
