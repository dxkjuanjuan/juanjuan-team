# Juanjuan Team 决策引擎

**用途**：Phase 4 方案审核阶段，convener 汇总三方独立意见时使用。
**来源**：借鉴 ChatGPT JAIT v1.0 Part 3 §5，融入 Claude 版本的落地约束。

---

## 一、对抗式辩论协议

Phase 4 方案审核阶段不新增 Agent，由现有 7 人分担四角色：

| 辩论角色 | 由谁扮演 | 职责 |
|---------|---------|------|
| **Proposer**（提案者） | architect | 出方案，回答"为什么是这个？为什么更好？" |
| **Critic**（批评者） | reviewer | 试图推翻方案，找隐藏假设、失败场景、安全风险 |
| **Optimizer**（优化者） | convener | 改进方案，找简化、提效、降本的可能 |
| **Judge**（裁决者） | leader | 最终评估，明显的对错直接定；技术性选择转卷卷 |

### 1.1 辩论规则

- 批评必须**攻击想法，不能攻击人**
- 反例："这方案不行"
- 正例："这方案在 X 条件下会失败，因为 Y"
- 胜出的方案不是"最受欢迎的"，而是"证据最强、风险最低的"

### 1.2 辩论流程

```
1. architect 提出 2-3 个方案（独立产出）
2. reviewer 独立挑每个方案的错（不看 architect 的内部推理）
3. convener 汇总 architect + reviewer 意见，提出优化版
4. leader 评估：
   - 明显对错 → 直接定夺
   - 技术性选择 → 转 convener，由卷卷定夺
5. 卷卷确认后，进入 Phase 5 设计文档
```

---

## 二、加权评分公式

convener 在汇总三方意见时，对每个方案打分：

```
Final Score = 
  技术可行性 × 30% + 
  用户价值 × 25% + 
  可维护性 × 20% + 
  安全性 × 15% + 
  成本效率 × 10%
```

### 2.1 各维度评分标准（0-100）

| 维度 | 权重 | 评分依据 |
|------|------|---------|
| **技术可行性** | 30% | 能否在现有技术栈下实现？依赖是否稳定？是否有成功案例？ |
| **用户价值** | 25% | 对卷卷实际需求的解决程度？是否解决核心痛点？ |
| **可维护性** | 20% | 3 个月后加新功能是否容易？代码结构是否清晰？是否符合 immutability/KISS/DRY/YAGNI？ |
| **安全性** | 15% | 是否有 OWASP Top 10 风险？是否有 secrets 泄露可能？权限边界是否清晰？ |
| **成本效率** | 10% | 开发工时？运行成本？维护成本？ |

### 2.2 评分示例

方案 A: 90×0.3 + 80×0.25 + 85×0.2 + 70×0.15 + 75×0.1 = 82.0
方案 B: 85×0.3 + 90×0.25 + 80×0.2 + 85×0.15 + 80×0.1 = 84.0
方案 C: 75×0.3 + 70×0.25 + 90×0.2 + 95×0.15 + 70×0.1 = 78.0

→ convener 推荐：方案 B（分数最高）

---

## 三、决策级别

| 级别 | 含义 | 行动 |
|------|------|------|
| **LEVEL A** | 明确胜出（最高分超过第二名 5+ 分） | 直接执行 |
| **LEVEL B** | 小幅领先（差距 2-5 分） | 推进但标注不确定项 |
| **LEVEL C** | 主要分歧（差距 < 2 分或 reviewer 有 critical 反对） | 升级 leader 裁决 |
| **LEVEL D** | 无法判定（信息不足或严重分歧） | 转 convener，请卷卷定夺 |

---

## 四、质量冲突的处理路径

reviewer 与 architect/coder/frontend 在产出质量上产生分歧时：

```
reviewer 一票否决权
  ↓
若 Safe/Normal 模式 → reviewer 否决即打回
若 Auto 模式 → leader 仲裁
若 YOLO 模式 → hive-mind 投票
```

---

## 五、产出格式

convener 在 Phase 4 汇总时输出：

```json
{
  "phase": "Phase 4",
  "solutions_evaluated": ["A", "B", "C"],
  "scores": {
    "A": {"feasibility": 90, "value": 80, "maintainability": 85, "security": 70, "cost": 75, "final": 82.0},
    "B": {"feasibility": 85, "value": 90, "maintainability": 80, "security": 85, "cost": 80, "final": 84.0}
  },
  "decision_level": "LEVEL_A | LEVEL_B | LEVEL_C | LEVEL_D",
  "recommended": "B",
  "reasoning": "<3 条以内核心理由>",
  "open_risks": ["<风险点 1>", "<风险点 2>"],
  "needs_user_decision": "<若是 LEVEL_C/D，写明需要卷卷决定的具体问题>"
}
```
