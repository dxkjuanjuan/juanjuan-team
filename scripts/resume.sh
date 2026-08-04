#!/bin/bash
# Juanjuan Team - v2.2 断电/断联恢复脚本
# 用法: ./resume.sh <project-dir>
#
# 场景: Claude Code 退出 / claude -p 真进程死了 / 电脑断电
# 流程:
#   1. 读 .convener/phase-state.json
#   2. 发现 in_progress agent -> 检查产出完整性
#   3. 不完整 -> cleanup-stale.sh 清理
#   4. 完整 -> 标记完成
#   5. 输出下一步建议（继续哪一 Phase）

set -uo pipefail

PROJECT_DIR="${1:?用法: resume.sh <project-dir>}"
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: 项目目录不存在: $PROJECT_DIR" >&2
    exit 1
fi

STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "❌ 无 phase-state.json，无法恢复"
    echo "  这个项目可能是 v1.8 之前建的，没有状态追踪"
    echo "  建议: 重新跑一遍"
    exit 1
fi

echo "=== Juanjuan Team 断联恢复 ==="
echo "项目: $PROJECT_DIR"
echo ""

# 读状态
CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
PHASE_STATUS=$(jq -r '.current_phase_status' "$STATE_FILE")
IN_PROGRESS_AGENT=$(jq -r '.in_progress_agent // empty' "$STATE_FILE")
COMPLETED_PHASES=$(jq -r '.completed_phases | join(", ")' "$STATE_FILE")
LAST_UPDATED=$(jq -r '.last_updated' "$STATE_FILE")

echo "当前 Phase: $CURRENT_PHASE"
echo "Phase 状态: $PHASE_STATUS"
echo "in_progress Agent: ${IN_PROGRESS_AGENT:-无}"
echo "已完成 Phase: $COMPLETED_PHASES"
echo "最后更新: $LAST_UPDATED"
echo ""

# 如果没有 in_progress agent，说明上次正常完成了
if [ -z "$IN_PROGRESS_AGENT" ] || [ "$IN_PROGRESS_AGENT" = "null" ]; then
    echo "✓ 上次正常完成，无需恢复"
    echo "  下一步: 跑下一 Phase"
    NEXT_PHASE=$(echo "$CURRENT_PHASE" | grep -oE '[0-9]+' | head -1)
    NEXT_PHASE=$((NEXT_PHASE + 1))
    echo "  建议: 继续 Phase $NEXT_PHASE"
    exit 0
fi

echo "=== 检查 in_progress Agent ($IN_PROGRESS_AGENT) 产出完整性 ==="

# 调 cleanup-stale.sh 检查（它会自动判断 + 清理）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/cleanup-stale.sh" "$PROJECT_DIR"

# 重新读状态（cleanup 可能改了）
PHASE_STATUS=$(jq -r '.current_phase_status' "$STATE_FILE")

echo ""
echo "=== 恢复建议 ==="

if [ "$PHASE_STATUS" = "pending_after_cleanup" ]; then
    echo "⚠️  上次 $IN_PROGRESS_AGENT 跑了一半就断了，脏数据已清理"
    echo "  建议: 重新 spawn $IN_PROGRESS_AGENT 跑 $CURRENT_PHASE"
    echo ""
    echo "命令:"
    echo "  bash scripts/global-spawn.sh <team-name> $IN_PROGRESS_AGENT <prompt-file> \"$PROJECT_DIR\""
else
    echo "✓ $IN_PROGRESS_AGENT 产出完整，可继续下一 Phase"
    jq '.current_phase_status = "completed" | .in_progress_agent = null | .in_progress_started_at = null' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    echo "  已自动标记为完成"
fi

echo ""
echo "=== 恢复完成 ==="
