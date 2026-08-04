#!/bin/bash
# Juanjuan Team — v1.9 teammate 状态检查
# 用法: ./team-status.sh <team-name>
#
# 检查 team 下所有 agent 的进程状态 + 输出文件状态

set -uo pipefail

TEAM_NAME="${1:?用法: team-status.sh <team-name>}"
TEAM_DIR="$HOME/.juanjuan/teams/${TEAM_NAME}"

if [ ! -d "$TEAM_DIR" ]; then
    echo "ERROR: team 目录不存在: $TEAM_DIR" >&2
    exit 1
fi

echo "=== Team: $TEAM_NAME ==="
echo "目录: $TEAM_DIR"
echo ""

echo "[1] Agent 进程状态"
for pid_file in "$TEAM_DIR"/*.pid; do
    [ -f "$pid_file" ] || continue
    role=$(basename "$pid_file" .pid)
    pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
        echo "  ✓ $role: running (PID $pid)"
    else
        echo "  ✗ $role: completed/dead (PID $pid)"
    fi
done
echo ""

echo "[2] 输出文件状态"
for output_file in "$TEAM_DIR"/outputs/*.jsonl; do
    [ -f "$output_file" ] || continue
    role=$(basename "$output_file" .jsonl)
    lines=$(wc -l < "$output_file" | tr -d ' ')
    size=$(du -h "$output_file" | cut -f1)
    echo "  $role.jsonl: $lines lines, $size"
done
echo ""

echo "[3] Mailbox 消息"
for msg_file in "$TEAM_DIR"/mailbox/*.json; do
    [ -f "$msg_file" ] || continue
    msg_name=$(basename "$msg_file")
    echo "  $msg_name"
done
echo ""

echo "[4] Audit 事件统计"
if [ -f "$TEAM_DIR/audit/events.jsonl" ]; then
    grep -oE '"event":"[^"]+"' "$TEAM_DIR/audit/events.jsonl" | sort | uniq -c
fi
