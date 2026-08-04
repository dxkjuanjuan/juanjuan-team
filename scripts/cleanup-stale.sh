#!/bin/bash
# Juanjuan Team — v1.9 脏数据清理
# 用法: ./cleanup-stale.sh <project-dir>
#
# 检查 in_progress agent 的产出文件是否完整
# 不完整的备份到 .audit/stale-<timestamp>/ + 删原文件

set -uo pipefail

PROJECT_DIR="${1:?用法: cleanup-stale.sh <project-dir>}"
STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "无 phase-state.json，跳过清理"
    exit 0
fi

# 读当前 in_progress agent
IN_PROGRESS_AGENT=$(jq -r '.in_progress_agent // empty' "$STATE_FILE")
IN_PROGRESS_PHASE=$(jq -r '.current_phase // empty' "$STATE_FILE")

if [ -z "$IN_PROGRESS_AGENT" ] || [ "$IN_PROGRESS_AGENT" = "null" ]; then
    echo "无 in_progress agent，跳过清理"
    exit 0
fi

echo "=== 检查 in_progress agent: $IN_PROGRESS_AGENT (Phase $IN_PROGRESS_PHASE) ==="
echo ""

TS=$(date +%Y%m%d%H%M%S)
STALE_DIR="$PROJECT_DIR/.audit/stale-$TS"
NEED_CLEANUP=false

case "$IN_PROGRESS_AGENT" in
    architect)
        DESIGN="$PROJECT_DIR/.architect/public/design.md"
        REASONING="$PROJECT_DIR/.architect/private/reasoning.md"

        # 检查 design.md 是否完整（有开头 + 结尾章节）
        if [ -f "$DESIGN" ]; then
            if head -1 "$DESIGN" | grep -q "^# Design" && tail -5 "$DESIGN" | grep -qi "风险\|风险点\|## 9"; then
                echo "  ✓ design.md 完整"
            else
                echo "  ✗ design.md 不完整（缺开头或结尾）→ 备份+清理"
                NEED_CLEANUP=true
            fi
        else
            echo "  - design.md 不存在"
        fi

        if [ -f "$REASONING" ]; then
            LINES=$(wc -l < "$REASONING")
            if [ "$LINES" -lt 5 ]; then
                echo "  ✗ reasoning.md 行数 $LINES < 5（不完整）→ 备份+清理"
                NEED_CLEANUP=true
            else
                echo "  ✓ reasoning.md 完整 ($LINES 行)"
            fi
        else
            echo "  - reasoning.md 不存在"
        fi
        ;;

    reviewer)
        REVIEW="$PROJECT_DIR/.reviewer/reviews/design-review.json"

        if [ -f "$REVIEW" ]; then
            if jq empty "$REVIEW" 2>/dev/null; then
                echo "  ✓ review.json 是合法 JSON"
            else
                echo "  ✗ review.json 不是合法 JSON → 备份+清理"
                NEED_CLEANUP=true
            fi
        else
            echo "  - review.json 不存在"
        fi
        ;;

    convener)
        echo "  convener 在跑 Phase $IN_PROGRESS_PHASE，无需清理（convener 是主会话，断电后手动续跑）"
        ;;

    *)
        echo "  未知 agent: $IN_PROGRESS_AGENT"
        ;;
esac

if [ "$NEED_CLEANUP" = "true" ]; then
    echo ""
    echo "=== 清理脏数据 ==="
    mkdir -p "$STALE_DIR"

    case "$IN_PROGRESS_AGENT" in
        architect)
            [ -f "$PROJECT_DIR/.architect/public/design.md" ] && cp "$PROJECT_DIR/.architect/public/design.md" "$STALE_DIR/design.md.stale"
            [ -f "$PROJECT_DIR/.architect/private/reasoning.md" ] && cp "$PROJECT_DIR/.architect/private/reasoning.md" "$STALE_DIR/reasoning.md.stale"
            rm -f "$PROJECT_DIR/.architect/public/design.md" "$PROJECT_DIR/.architect/private/reasoning.md"
            ;;
        reviewer)
            [ -f "$PROJECT_DIR/.reviewer/reviews/design-review.json" ] && cp "$PROJECT_DIR/.reviewer/reviews/design-review.json" "$STALE_DIR/design-review.json.stale"
            rm -f "$PROJECT_DIR/.reviewer/reviews/design-review.json"
            ;;
    esac

    echo "  脏数据备份到: $STALE_DIR"
    echo "  原文件已删除，可重新 spawn $IN_PROGRESS_AGENT"

    # 更新 phase-state
    jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.current_phase_status = "pending_after_cleanup" | .in_progress_agent = null | .in_progress_started_at = null | .last_updated = $ts' \
       "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
else
    echo ""
    echo "✓ 无脏数据，无需清理"
fi
