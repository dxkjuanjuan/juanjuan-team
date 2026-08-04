#!/bin/bash
# Juanjuan Team — v1.9 phase-state 管理
# 用法:
#   ./phase-state.sh init <project-dir>
#   ./phase-state.sh update <project-dir> <current-phase> <status> <agent>
#   ./phase-state.sh read <project-dir>
#   ./phase-state.sh next-phase <project-dir>

set -uo pipefail

CMD="${1:?用法: phase-state.sh init|update|read|next-phase ...}"
shift

case "$CMD" in
    init)
        PROJECT_DIR="${1:?需要 project-dir}"
        mkdir -p "$PROJECT_DIR/.convener"
        STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"
        if [ -f "$STATE_FILE" ]; then
            echo "WARN: phase-state.json 已存在，跳过 init" >&2
            exit 0
        fi
        TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        cat > "$STATE_FILE" <<EOF
{
  "task_id": "$(basename "$PROJECT_DIR")",
  "current_phase": "Phase 0",
  "current_phase_status": "in_progress",
  "in_progress_agent": "convener",
  "in_progress_started_at": "$TS",
  "completed_phases": [],
  "last_updated": "$TS"
}
EOF
        echo "$STATE_FILE"
        ;;

    update)
        PROJECT_DIR="${1:?需要 project-dir}"
        PHASE="${2:?需要 phase}"
        STATUS="${3:?需要 status}"
        AGENT="${4:-}"
        STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"

        if [ ! -f "$STATE_FILE" ]; then
            echo "ERROR: phase-state.json 不存在: $STATE_FILE" >&2
            exit 1
        fi

        TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

        if [ "$STATUS" = "completed" ]; then
            # 当前 phase 标记完成，进入下一 phase
            CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
            COMPLETED=$(jq -r '.completed_phases' "$STATE_FILE")
            # 把当前 phase 加到 completed_phases
            NEW_COMPLETED=$(echo "$COMPLETED" | jq --arg p "$CURRENT_PHASE" '. + [$p]')
            # 计算下一 phase（简化：从 Phase N → Phase N+1）
            PHASE_NUM=$(echo "$CURRENT_PHASE" | grep -oE '[0-9]+' | head -1)
            NEXT_NUM=$((PHASE_NUM + 1))
            NEXT_PHASE="Phase $NEXT_NUM"

            jq --arg cp "$CURRENT_PHASE" \
               --arg np "$NEXT_PHASE" \
               --arg ts "$TS" \
               --argjson completed "$NEW_COMPLETED" \
               '.completed_phases = $completed | .current_phase = $np | .current_phase_status = "pending" | .in_progress_agent = null | .in_progress_started_at = null | .last_updated = $ts' \
               "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        else
            # 标记当前 phase in_progress + agent
            jq --arg p "$PHASE" \
               --arg s "$STATUS" \
               --arg a "$AGENT" \
               --arg ts "$TS" \
               '.current_phase = $p | .current_phase_status = $s | .in_progress_agent = $a | .in_progress_started_at = $ts | .last_updated = $ts' \
               "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        fi

        cat "$STATE_FILE" | jq .
        ;;

    read)
        PROJECT_DIR="${1:?需要 project-dir}"
        STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"

        if [ ! -f "$STATE_FILE" ]; then
            echo "ERROR: phase-state.json 不存在" >&2
            exit 1
        fi

        cat "$STATE_FILE" | jq .
        ;;

    next-phase)
        PROJECT_DIR="${1:?需要 project-dir}"
        STATE_FILE="$PROJECT_DIR/.convener/phase-state.json"

        if [ ! -f "$STATE_FILE" ]; then
            echo "ERROR: phase-state.json 不存在" >&2
            exit 1
        fi

        CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
        PHASE_NUM=$(echo "$CURRENT_PHASE" | grep -oE '[0-9]+' | head -1)
        NEXT_NUM=$((PHASE_NUM + 1))
        NEXT_PHASE="Phase $NEXT_NUM"

        echo "$NEXT_PHASE"
        ;;

    *)
        echo "未知命令: $CMD" >&2
        exit 1
        ;;
esac
