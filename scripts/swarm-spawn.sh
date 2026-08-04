#!/bin/bash
# Juanjuan Team — 7 人 Agent spawn 文档脚本（v1.5）
# 用法: ./swarm-spawn.sh <项目目录> <模式>
#
# ⚠️ 本脚本仅文档化 spawn 顺序与参数，不真正 spawn Agent。
# 真实 spawn 由 convener 在 Claude Code 会话内通过 MCP 工具调用：
#   mcp__claude-flow__swarm_init
#   mcp__claude-flow__agent_spawn × 7
# 本脚本的价值：作为 convener 调 MCP 时的参数清单参考，便于回溯调试。

set -euo pipefail

PROJECT_DIR="${1:-}"
MODE="${2:-safe}"

PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: 项目目录不存在: $PROJECT_DIR"
    exit 1
fi

echo "=== Juanjuan Team Swarm 启动 ==="
echo "项目目录: $PROJECT_DIR"
echo "模式: $MODE"
echo ""

# === Step 1: swarm_init ===
echo "[Step 1] 初始化 swarm (hierarchical-mesh, max 10 agents)"
echo "MCP 调用: mcp__claude-flow__swarm_init"
echo "  config:"
echo "    topology: hierarchical-mesh"
echo "    strategy: specialized"
echo "    maxAgents: 10"
echo "    consensusMechanism: raft"
echo "    skill: juanjuan-team"
echo "    teamMode: $MODE"
echo ""

# === Step 2: spawn 7 Agents（并行） ===
echo "[Step 2] 并行 spawn 7 个 Agent"
echo "MCP 调用: mcp__claude-flow__agent_spawn × 7"
echo ""

# Agent 1: Leader
echo "  [1/7] Leader (调控者)"
echo "    agentType: leader"
echo "    model: opus (调控需要深度推理)"
echo "    task: 统筹团队 + 介入三方审核冲突 + 明显情况定夺"
echo ""

# Agent 2: Convener
echo "  [2/7] Convener (主对接 + 总审核)"
echo "    agentType: convener"
echo "    model: opus (对话 + 总审核需要最强)"
echo "    task: 唯一对外窗口 + 跟卷卷对话 + 汇总三方意见"
echo ""

# Agent 3: Architect
echo "  [3/7] Architect (架构师)"
echo "    agentType: architect"
echo "    model: sonnet (技术选型)"
echo "    task: 方案设计 + 技术可行性审核 + 任务拆解"
echo ""

# Agent 4: Frontend
echo "  [4/7] Frontend (前端工程师)"
echo "    agentType: frontend"
echo "    model: sonnet"
echo "    task: React/Vue + shadcn/ui + Ant Design"
echo ""

# Agent 5: Coder
echo "  [5/7] Coder (后端工程师)"
echo "    agentType: coder"
echo "    model: sonnet"
echo "    task: 业务逻辑 + API + 数据层 + 80% 测试覆盖"
echo ""

# Agent 6: Reviewer
echo "  [6/7] Reviewer (安全审查)"
echo "    agentType: reviewer"
echo "    model: opus (审查需要深度)"
echo "    task: OWASP Top 10 + 测试覆盖率 + 文档审查"
echo ""

# Agent 7: Docs-Researcher
echo "  [7/7] Docs-Researcher (文档 + 资料查找 + 浏览器调试)"
echo "    agentType: docs-researcher"
echo "    model: sonnet"
echo "    task: memory_search + kimi-webbridge + spec 文档 + 存记忆"
echo ""

# === Step 3: 消息拓扑 ===
echo "[Step 3] 消息拓扑"
echo "  卷卷 ←→ convener ←→ leader"
echo "                ↑↓"
echo "    ┌──────────┬──────────┬──────────┐"
echo "    │          │          │          │"
echo "  architect  frontend  coder    reviewer"
echo "    │                              │"
echo "    └── docs-researcher ←─────────┘"
echo ""
echo "  独立审核落地:"
echo "    Phase 4/6/8 三方审核时, convener 并行调用"
echo "    architect + reviewer + docs-researcher"
echo "    禁止把已收到的意见转发给还未提交意见的一方"
echo ""

# === Step 4: 模式行为初始化 ===
echo "[Step 4] 模式行为初始化 ($MODE)"
case "$MODE" in
    safe)
        echo "  Safe 模式: 每阶段都审核 + 卷卷确认"
        echo "  冲突处理: A (明显情况 Leader 定, 其他转卷卷)"
        ;;
    manual)
        echo "  Manual 模式: 团队只做头脑风暴辅助, 卷卷完全审核 (原 Normal, v1.4 改名)"
        echo "  冲突处理: A (全转卷卷, reviewer 否决权降级为建议)"
        ;;
    normal)
        echo "  [deprecated] Normal 模式: 同 Manual (向后兼容)"
        echo "  冲突处理: A (全转卷卷)"
        ;;
    auto)
        echo "  Auto 模式: 团队审核, 难抉择转卷卷"
        echo "  冲突处理: B (Leader 拍板, 重大冲突才转卷卷)"
        ;;
    yolo)
        echo "  YOLO 模式: 全权放给团队, hive-mind 投票"
        echo "  冲突处理: C (hive-mind 共识投票, 多数派胜)"
        ;;
    *)
        echo "  ERROR: 未知模式 $MODE (应为 safe/manual/auto/yolo, normal 为 deprecated alias)"
        exit 1
        ;;
esac

echo ""
echo "=== Swarm 启动完成 ==="
echo "下一步: convener 跟卷卷进入 Phase 0 头脑风暴"
