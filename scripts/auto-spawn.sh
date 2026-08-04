#!/bin/bash
# Juanjuan Team - v2.2 自动 spawn wrapper
# 用法: ./auto-spawn.sh <project-dir> <team-name> <role> <prompt-file>
#
# 包装 global-spawn.sh，自动:
#   1. spawn 前更新 phase-state.json（标 in_progress）
#   2. 调 global-spawn.sh 启动 claude -p 真进程
#   3. 等进程完成
#   4. spawn 后更新 phase-state.json（标 completed）
#   5. 自动写 audit event（agent_spawn + agent_complete）
#
# 这样断电时 phase-state.json 始终是最新的，resume.sh 能正确恢复

set -uo pipefail

PROJECT_DIR="${1:?用法: auto-spawn.sh <project-dir> <team-name> <role> <prompt-file>}"
TEAM_NAME="${2:?用法: auto-spawn.sh <project-dir> <team-name> <role> <prompt-file>}"
ROLE="${3:?用法: auto-spawn.sh <project-dir> <team-name> <role> <prompt-file>}"
PROMPT_FILE="${4:?用法: auto-spawn.sh <project-dir> <team-name> <role> <prompt-file>}"

PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. spawn 前更新 phase-state
bash "$SCRIPT_DIR/phase-state.sh" update "$PROJECT_DIR" "Phase ?" "in_progress" "$ROLE" > /dev/null

# 2. 写 agent_spawn audit event
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROMPT_HASH=$(shasum -a 256 "$PROMPT_FILE" 2>/dev/null | cut -d' ' -f1)
echo "{\"event\":\"agent_spawn\",\"agent\":\"$ROLE\",\"team\":\"$TEAM_NAME\",\"timestamp\":\"$TS\",\"spawn_method\":\"claude -p (real process)\",\"prompt_hash\":\"sha256:$PROMPT_HASH\"}" >> "$PROJECT_DIR/.audit/events.jsonl"

# 3. 调 global-spawn.sh 启动真进程
bash "$SCRIPT_DIR/global-spawn.sh "$TEAM_NAME" "$ROLE" "$PROMPT_FILE" "$PROJECT_DIR""
if [ $? -ne 0 ]; then
    echo "ERROR: global-spawn.sh 失败" >&2
    exit 1
fi

# 4. 等进程完成
PID=$(cat "$HOME/.juanjuan/teams/$TEAM_NAME/$ROLE.pid" 2>/dev/null)
if [ -z "$PID" ]; then
    echo "ERROR: 找不到 PID 文件" >&2
    exit 1
fi

echo "等 $ROLE (PID $PID) 完成..."
START=$(date +%s)
while kill -0 "$PID" 2>/dev/null; do
    sleep 30
    ELAPSED=$(($(date +%s) - START))
    echo "[$ELAPSED s] $ROLE 还在跑..."
    if [ $ELAPSED -gt 1800 ]; then
        echo "超时 30 分钟，杀进程"
        kill "$PID" 2>/dev/null
        break
    fi
done
END=$(date +%s)
DURATION=$((END - START))

# 5. 写 agent_complete audit event
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"event\":\"agent_complete\",\"agent\":\"$ROLE\",\"team\":\"$TEAM_NAME\",\"timestamp\":\"$TS\",\"pid\":$PID,\"duration_seconds\":$DURATION,\"spawn_method\":\"claude -p (real process)\"}" >> "$PROJECT_DIR/.audit/events.jsonl"

# 6. 更新 phase-state（标 completed）
bash "$SCRIPT_DIR/phase-state.sh" update "$PROJECT_DIR" "Phase ?" "completed" "$ROLE" > /dev/null

echo "✓ $ROLE 完成 (耗时 ${DURATION}s)"
